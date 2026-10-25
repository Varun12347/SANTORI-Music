import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track.dart';
import 'api_service.dart';

enum SantoriRepeatMode { off, all, one }

class AudioPlaybackService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Track? _currentTrack;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(seconds: 180);
  double _volume = 0.85;
  bool _shuffle = false;
  SantoriRepeatMode _repeat = SantoriRepeatMode.off;
  List<Track> _queue = [];
  final Set<String> _likedIds = {};
  List<Track> _likedTracks = [];

  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _completeSub;
  Timer? _synthSimTimer;

  AudioPlaybackService() {
    _initAudioPlayer();
    _loadLikedTracks();
    _initDemoQueue();
  }

  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;
  bool get shuffle => _shuffle;
  SantoriRepeatMode get repeat => _repeat;
  List<Track> get queue => _queue;
  List<Track> get likedTracks => _likedTracks;

  bool isLiked(String id) => _likedIds.contains(id);

  void _initAudioPlayer() {
    _player.setVolume(_volume);

    _posSub = _player.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    _durSub = _player.onDurationChanged.listen((dur) {
      _totalDuration = dur;
      notifyListeners();
    });

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _completeSub = _player.onPlayerComplete.listen((_) {
      if (_repeat == SantoriRepeatMode.one) {
        _player.seek(Duration.zero);
        _player.resume();
      } else {
        nextTrack();
      }
    });
  }

  void _initDemoQueue() {
    _queue = [
      const Track(
        id: 'demo-1',
        title: 'Paper Horizon (Demo)',
        artist: 'SANTORI Collective',
        album: 'Acoustic Sheets',
        duration: 195,
        image: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80',
        hue: 215,
        isDemo: true,
      ),
      const Track(
        id: 'demo-2',
        title: 'Graphite Echoes (Demo)',
        artist: 'Desk Quartet',
        album: 'Ruled Notebook Vol. 1',
        duration: 210,
        image: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80',
        hue: 140,
        isDemo: true,
      ),
      const Track(
        id: 'demo-3',
        title: 'Ocean Midnight Tapes (Demo)',
        artist: 'SANTORI Waves',
        album: 'Midnight Drifts',
        duration: 240,
        image: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=80',
        hue: 195,
        isDemo: true,
      ),
    ];
    _currentTrack = _queue[0];
    _totalDuration = Duration(seconds: _currentTrack!.duration);
  }

  Future<void> _loadLikedTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('santori_likes') ?? ['demo-1'];
      _likedIds.addAll(ids);

      final backendLikes = await ApiService.getLikedTracks();
      if (backendLikes.isNotEmpty) {
        _likedTracks = backendLikes;
        for (var t in backendLikes) {
          _likedIds.add(t.id);
        }
      } else {
        _likedTracks = _queue.where((t) => _likedIds.contains(t.id)).toList();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> playTrack(Track track, {List<Track>? newQueue}) async {
    _synthSimTimer?.cancel();
    _currentTrack = track;
    _currentPosition = Duration.zero;
    _totalDuration = Duration(seconds: track.duration);

    if (newQueue != null) {
      _queue = newQueue;
    } else if (!_queue.any((t) => t.id == track.id)) {
      _queue.insert(0, track);
    }

    notifyListeners();

    if (track.streamUrl != null && track.streamUrl!.isNotEmpty) {
      try {
        await _player.stop();
        await _player.play(UrlSource(track.streamUrl!));
      } catch (e) {
        debugPrint(
          'Stream play error, falling back to simulated synth timer: $e',
        );
        _startSynthSimulation(track);
      }
    } else {
      _startSynthSimulation(track);
    }
  }

  void _startSynthSimulation(Track track) {
    _isPlaying = true;
    notifyListeners();
    _synthSimTimer?.cancel();
    _synthSimTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) return;
      if (_currentPosition.inSeconds >= _totalDuration.inSeconds) {
        if (_repeat == SantoriRepeatMode.one) {
          _currentPosition = Duration.zero;
        } else {
          nextTrack();
        }
      } else {
        _currentPosition += const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  Future<void> togglePlay() async {
    if (_currentTrack == null) {
      if (_queue.isNotEmpty) playTrack(_queue[0]);
      return;
    }

    if (_isPlaying) {
      _isPlaying = false;
      await _player.pause();
      _synthSimTimer?.cancel();
      notifyListeners();
    } else {
      if (_currentTrack!.streamUrl != null &&
          _currentTrack!.streamUrl!.isNotEmpty) {
        try {
          await _player.resume();
        } catch (_) {
          playTrack(_currentTrack!);
        }
      } else {
        _startSynthSimulation(_currentTrack!);
      }
      _isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (_isPlaying) {
      _isPlaying = false;
      await _player.pause();
      _synthSimTimer?.cancel();
      notifyListeners();
    }
  }

  void nextTrack() {
    if (_queue.isEmpty) return;
    int currentIndex = _queue.indexWhere((t) => t.id == _currentTrack?.id);
    int nextIndex = 0;

    if (_shuffle) {
      nextIndex = (currentIndex + 1) % _queue.length;
    } else if (currentIndex != -1) {
      nextIndex = currentIndex + 1;
      if (nextIndex >= _queue.length) {
        if (_repeat == SantoriRepeatMode.all) {
          nextIndex = 0;
        } else {
          pause();
          return;
        }
      }
    }
    playTrack(_queue[nextIndex]);
  }

  void prevTrack() {
    // If more than 3s in, restarts current track
    if (_currentPosition.inSeconds > 3) {
      seek(Duration.zero);
      return;
    }
    if (_queue.isEmpty) return;
    int currentIndex = _queue.indexWhere((t) => t.id == _currentTrack?.id);
    int prevIndex = _queue.length - 1;
    if (currentIndex > 0) {
      prevIndex = currentIndex - 1;
    }
    playTrack(_queue[prevIndex]);
  }

  Future<void> seek(Duration position) async {
    _currentPosition = position;
    notifyListeners();
    if (_currentTrack?.streamUrl != null &&
        _currentTrack!.streamUrl!.isNotEmpty) {
      await _player.seek(position);
    }
  }

  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeat) {
      case SantoriRepeatMode.off:
        _repeat = SantoriRepeatMode.all;
        break;
      case SantoriRepeatMode.all:
        _repeat = SantoriRepeatMode.one;
        break;
      case SantoriRepeatMode.one:
        _repeat = SantoriRepeatMode.off;
        break;
    }
    notifyListeners();
  }

  Future<void> toggleLike(Track track) async {
    final alreadyLiked = _likedIds.contains(track.id);
    if (alreadyLiked) {
      _likedIds.remove(track.id);
      _likedTracks.removeWhere((t) => t.id == track.id);
      ApiService.removeLike(track.id);
    } else {
      _likedIds.add(track.id);
      _likedTracks.insert(0, track);
      ApiService.addLike(track);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('santori_likes', _likedIds.toList());
    } catch (_) {}
  }

  void addToQueue(Track track) {
    _queue.add(track);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _synthSimTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}

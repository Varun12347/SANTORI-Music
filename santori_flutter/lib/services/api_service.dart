import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';
import '../models/track.dart';

class ApiService {
  static const String defaultProductionApiUrl = 'https://santori-music-api.onrender.com';
  static const String defaultAndroidLocalUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  static const String _envBaseUrl = String.fromEnvironment('API_URL');
  static String? _customBaseUrl;

  static bool lastFetchSucceeded = true;
  static String? lastErrorMessage;

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.trim().isNotEmpty) {
      return _customBaseUrl!.trim();
    }
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl.trim();
    }
    return defaultProductionApiUrl;
  }

  static Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      final ok = res.statusCode == 200;
      lastFetchSucceeded = ok;
      return ok;
    } catch (e) {
      lastFetchSucceeded = false;
      lastErrorMessage = e.toString();
      return false;
    }
  }

  static Future<void> initBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('santori_api_url');
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _customBaseUrl = savedUrl.trim();
      }
    } catch (_) {}
  }

  static Future<void> setCustomBaseUrl(String url, {bool persist = true}) async {
    _customBaseUrl = url.trim();
    if (persist) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (url.trim().isEmpty) {
          await prefs.remove('santori_api_url');
        } else {
          await prefs.setString('santori_api_url', url.trim());
        }
      } catch (_) {}
    }
  }

  // --- Search Tracks ---
  static Future<List<Track>> searchTracks(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/search?q=${Uri.encodeComponent(query)}&page=$page&limit=$limit',
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        lastFetchSucceeded = true;
        lastErrorMessage = null;
        return data.map((json) => Track.fromJson(json)).toList();
      } else {
        lastFetchSucceeded = false;
        lastErrorMessage = 'Server error code: ${response.statusCode}';
      }
    } catch (e) {
      lastFetchSucceeded = false;
      lastErrorMessage = e.toString();
      debugPrint('ApiService search error: $e');
    }
    return [];
  }

  // --- Trending Tracks ---
  static Future<List<Track>> getTrendingTracks({
    String language = 'hindi',
  }) async {
    final uri = Uri.parse('$baseUrl/api/trending?language=$language');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        lastFetchSucceeded = true;
        lastErrorMessage = null;
        return data.map((json) => Track.fromJson(json)).toList();
      } else {
        lastFetchSucceeded = false;
        lastErrorMessage = 'Server error code: ${response.statusCode}';
      }
    } catch (e) {
      lastFetchSucceeded = false;
      lastErrorMessage = e.toString();
      debugPrint('ApiService trending error: $e');
    }
    return _getFallbackDemoTracks();
  }

  // --- Likes ---
  static Future<List<Track>> getLikedTracks() async {
    final uri = Uri.parse('$baseUrl/api/likes');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Track.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('ApiService getLikes error: $e');
    }
    return [];
  }

  static Future<bool> addLike(Track track) async {
    final uri = Uri.parse('$baseUrl/api/likes');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': track.id,
              'title': track.title,
              'artist': track.artist,
              'album': track.album,
              'duration': track.duration,
              'image': track.image,
              'stream_url': track.streamUrl ?? '',
            }),
          )
          .timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService addLike error: $e');
      return false;
    }
  }

  static Future<bool> removeLike(String songId) async {
    final uri = Uri.parse('$baseUrl/api/likes/$songId');
    try {
      final response = await http
          .delete(uri)
          .timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService removeLike error: $e');
      return false;
    }
  }

  // --- Playlists ---
  static Future<List<Playlist>> getPlaylists() async {
    final uri = Uri.parse('$baseUrl/api/playlists');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Playlist.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('ApiService getPlaylists error: $e');
    }
    return [];
  }

  static Future<Playlist?> createPlaylist(
    String name,
    String description,
  ) async {
    final uri = Uri.parse('$baseUrl/api/playlists');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'description': description}),
          )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return Playlist.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint('ApiService createPlaylist error: $e');
    }
    return null;
  }

  static Future<bool> deletePlaylist(int id) async {
    final uri = Uri.parse('$baseUrl/api/playlists/$id');
    try {
      final response = await http
          .delete(uri)
          .timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService deletePlaylist error: $e');
      return false;
    }
  }

  // --- Lyrics ---
  static Future<String?> getLyrics(String songId) async {
    final uri = Uri.parse('$baseUrl/api/lyrics/$songId');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['lyrics'];
      }
    } catch (e) {
      debugPrint('ApiService getLyrics error: $e');
    }
    return null;
  }

  static List<Track> _getFallbackDemoTracks() {
    return const [
      Track(
        id: 'demo-1',
        title: 'Paper Horizon (Demo)',
        artist: 'SANTORI Collective',
        album: 'Acoustic Sheets',
        duration: 195,
        image: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80',
        hue: 215,
        isDemo: true,
      ),
      Track(
        id: 'demo-2',
        title: 'Graphite Echoes (Demo)',
        artist: 'Desk Quartet',
        album: 'Ruled Notebook Vol. 1',
        duration: 210,
        image: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80',
        hue: 140,
        isDemo: true,
      ),
      Track(
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
  }
}

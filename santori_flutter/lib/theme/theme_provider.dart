import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'paper_tokens.dart';
import '../models/preset.dart';

class ThemeProvider extends ChangeNotifier {
  PaperShade _shade = PaperShade.stone;
  InkColor _ink = InkColor.blueBlack;
  double _grain = 0.35;
  bool _tilted = true;
  VisualizerStyle _visualizer = VisualizerStyle.pencil;
  bool _autoShade = false;

  int? _sleepTimerMinutes;
  int? _sleepRemainingSeconds;
  Timer? _sleepTimer;
  Timer? _clockCheckTimer;

  List<SavedLookPreset> _presets = [
    const SavedLookPreset(
      name: 'Study Session',
      shade: PaperShade.stone,
      ink: InkColor.blueBlack,
      grain: 0.35,
      tilted: true,
      visualizer: VisualizerStyle.pencil,
    ),
    const SavedLookPreset(
      name: 'Night Glow',
      shade: PaperShade.charcoal,
      ink: InkColor.blueBlack,
      grain: 0.25,
      tilted: true,
      visualizer: VisualizerStyle.rings,
    ),
    const SavedLookPreset(
      name: 'Ocean Drift',
      shade: PaperShade.oceanDark,
      ink: InkColor.neonCyan,
      grain: 0.15,
      tilted: false,
      visualizer: VisualizerStyle.ink,
    ),
    const SavedLookPreset(
      name: 'Dark Purple',
      shade: PaperShade.darkPurple,
      ink: InkColor.electricViolet,
      grain: 0.15,
      tilted: true,
      visualizer: VisualizerStyle.pencil,
    ),
  ];

  VoidCallback? onSleepEnd;

  ThemeProvider() {
    _loadPreferences();
    _startClockCheck();
  }

  PaperShade get shade => _shade;
  InkColor get ink => _ink;
  double get grain => _grain;
  bool get tilted => _tilted;
  VisualizerStyle get visualizer => _visualizer;
  bool get autoShade => _autoShade;
  int? get sleepTimerMinutes => _sleepTimerMinutes;
  int? get sleepRemainingSeconds => _sleepRemainingSeconds;
  List<SavedLookPreset> get presets => _presets;

  ShadeTokens get currentShade => PaperTokens.shades[_shade]!;
  InkTokens get currentInkTokens => PaperTokens.inks[_ink]!;
  Color get inkColor => currentShade.isDark
      ? currentInkTokens.darkValue
      : currentInkTokens.lightValue;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shadeStr = prefs.getString('paper_shade');
      if (shadeStr != null) {
        _shade = PaperShade.values.firstWhere(
          (s) => s.name == shadeStr,
          orElse: () => PaperShade.stone,
        );
      }
      final inkStr = prefs.getString('ink_color');
      if (inkStr != null) {
        _ink = InkColor.values.firstWhere(
          (i) => i.name == inkStr,
          orElse: () => InkColor.blueBlack,
        );
      }
      _grain = prefs.getDouble('grain') ?? 0.35;
      _tilted = prefs.getBool('tilted') ?? true;
      final vizStr = prefs.getString('visualizer');
      if (vizStr != null) {
        _visualizer = VisualizerStyle.values.firstWhere(
          (v) => v.name == vizStr,
          orElse: () => VisualizerStyle.pencil,
        );
      }
      _autoShade = prefs.getBool('auto_shade') ?? false;

      final presetsRaw = prefs.getString('saved_presets');
      if (presetsRaw != null) {
        List<dynamic> list = jsonDecode(presetsRaw);
        _presets = list.map((item) => SavedLookPreset.fromJson(item)).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('paper_shade', _shade.name);
      await prefs.setString('ink_color', _ink.name);
      await prefs.setDouble('grain', _grain);
      await prefs.setBool('tilted', _tilted);
      await prefs.setString('visualizer', _visualizer.name);
      await prefs.setBool('auto_shade', _autoShade);
      await prefs.setString(
        'saved_presets',
        jsonEncode(_presets.map((p) => p.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  void setShade(PaperShade newShade) {
    _shade = newShade;
    _savePreferences();
    notifyListeners();
  }

  void setInk(InkColor newInk) {
    _ink = newInk;
    _savePreferences();
    notifyListeners();
  }

  void setGrain(double newGrain) {
    _grain = newGrain.clamp(0.0, 0.7);
    _savePreferences();
    notifyListeners();
  }

  void setTilt(bool isTilted) {
    _tilted = isTilted;
    _savePreferences();
    notifyListeners();
  }

  void setVisualizer(VisualizerStyle style) {
    _visualizer = style;
    _savePreferences();
    notifyListeners();
  }

  void setAutoShade(bool active) {
    _autoShade = active;
    if (_autoShade) {
      _applyTimeOfDay();
    }
    _savePreferences();
    notifyListeners();
  }

  void _startClockCheck() {
    _clockCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_autoShade) {
        _applyTimeOfDay();
      }
    });
  }

  void _applyTimeOfDay() {
    final hour = DateTime.now().hour;
    PaperShade calculated;
    if (hour < 17) {
      calculated = PaperShade.stone;
    } else if (hour >= 17 && hour < 21) {
      calculated = PaperShade.slate;
    } else {
      calculated = PaperShade.charcoal;
    }
    if (_shade != calculated) {
      _shade = calculated;
      notifyListeners();
    }
  }

  // Sleep Timer
  void setSleepTimer(int? minutes) {
    _sleepTimer?.cancel();
    _sleepTimerMinutes = minutes;
    if (minutes == null) {
      _sleepRemainingSeconds = null;
    } else {
      _sleepRemainingSeconds = minutes * 60;
      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_sleepRemainingSeconds == null || _sleepRemainingSeconds! <= 0) {
          timer.cancel();
          _sleepTimerMinutes = null;
          _sleepRemainingSeconds = null;
          if (onSleepEnd != null) {
            onSleepEnd!();
          }
          notifyListeners();
        } else {
          _sleepRemainingSeconds = _sleepRemainingSeconds! - 1;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  // Presets
  bool savePreset(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _presets.length >= 8) return false;

    _presets.removeWhere((p) => p.name.toLowerCase() == trimmed.toLowerCase());
    _presets.add(
      SavedLookPreset(
        name: trimmed,
        shade: _shade,
        ink: _ink,
        grain: _grain,
        tilted: _tilted,
        visualizer: _visualizer,
      ),
    );
    _savePreferences();
    notifyListeners();
    return true;
  }

  void applyPreset(SavedLookPreset preset) {
    _shade = preset.shade;
    _ink = preset.ink;
    _grain = preset.grain;
    _tilted = preset.tilted;
    _visualizer = preset.visualizer;
    _savePreferences();
    notifyListeners();
  }

  void deletePreset(String name) {
    _presets.removeWhere((p) => p.name == name);
    _savePreferences();
    notifyListeners();
  }

  String exportLookCode() {
    final map = {
      'shade': _shade.name,
      'ink': _ink.name,
      'grain': _grain,
      'tilt': _tilted ? '1' : '0',
      'visualizer': _visualizer.name,
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }

  String? importLookCode(String code) {
    try {
      final decoded = utf8.decode(base64Decode(code.trim()));
      final json = jsonDecode(decoded);

      final shadeStr = json['shade']?.toString();
      final inkStr = json['ink']?.toString();
      final vizStr = json['visualizer']?.toString();
      final grainVal = json['grain'];

      final shade = PaperShade.values.firstWhere((s) => s.name == shadeStr);
      final ink = InkColor.values.firstWhere((i) => i.name == inkStr);
      final viz = VisualizerStyle.values.firstWhere((v) => v.name == vizStr);

      if (grainVal is! num || grainVal < 0 || grainVal > 0.7) {
        return 'That code is not valid.';
      }

      _shade = shade;
      _ink = ink;
      _visualizer = viz;
      _grain = grainVal.toDouble();
      _tilted = json['tilt'] == '1' || json['tilt'] == true;

      _savePreferences();
      notifyListeners();
      return null;
    } catch (_) {
      return 'That code is not valid.';
    }
  }

  void restoreDefaults() {
    _shade = PaperShade.stone;
    _ink = InkColor.blueBlack;
    _grain = 0.35;
    _tilted = true;
    _visualizer = VisualizerStyle.pencil;
    _autoShade = false;
    _savePreferences();
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _clockCheckTimer?.cancel();
    super.dispose();
  }
}

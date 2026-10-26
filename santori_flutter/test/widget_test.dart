import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:santori_flutter/models/preset.dart';
import 'package:santori_flutter/models/track.dart';
import 'package:santori_flutter/services/api_service.dart';
import 'package:santori_flutter/theme/paper_tokens.dart';

void main() {
  group('Track Model Tests', () {
    test('Track correctly parses from JSON', () {
      final json = {
        'id': 'kesariya_1',
        'title': 'Kesariya',
        'artist': 'Arijit Singh',
        'album': 'Brahmastra',
        'duration': 268,
        'image': 'https://c.saavncdn.com/871/Brahmastra-500x500.jpg',
        'stream_url': 'https://aac.saavncdn.com/871/sample_320.mp4',
        'is_demo': false,
        'hue': 210,
      };

      final track = Track.fromJson(json);
      expect(track.id, 'kesariya_1');
      expect(track.title, 'Kesariya');
      expect(track.artist, 'Arijit Singh');
      expect(track.duration, 268);
      expect(track.streamUrl, 'https://aac.saavncdn.com/871/sample_320.mp4');
      expect(track.isDemo, false);
    });
  });

  group('Look Preset & Whitelist Validation Tests', () {
    test('Validates a standard Stone look preset JSON', () {
      final preset = const SavedLookPreset(
        name: 'Study Look',
        shade: PaperShade.stone,
        ink: InkColor.blueBlack,
        grain: 0.35,
        tilted: true,
        visualizer: VisualizerStyle.pencil,
      );

      final json = preset.toJson();
      final recovered = SavedLookPreset.fromJson(json);

      expect(recovered.name, 'Study Look');
      expect(recovered.shade, PaperShade.stone);
      expect(recovered.ink, InkColor.blueBlack);
      expect(recovered.grain, 0.35);
      expect(recovered.tilted, true);
    });

    test('Validates Dark Purple and Ocean Dark theme tokens', () {
      final purpleShade = PaperTokens.shades[PaperShade.darkPurple]!;
      expect(purpleShade.isDark, true);
      expect(purpleShade.name, 'Dark Purple');

      final oceanShade = PaperTokens.shades[PaperShade.oceanDark]!;
      expect(oceanShade.isDark, true);
      expect(oceanShade.name, 'Ocean Dark');
    });

    test('Encodes and decodes base64 look code successfully', () {
      final map = {
        'shade': 'darkPurple',
        'ink': 'electricViolet',
        'grain': 0.15,
        'tilt': '1',
        'visualizer': 'pencil',
      };
      final code = base64Encode(utf8.encode(jsonEncode(map)));
      final decodedMap = jsonDecode(utf8.decode(base64Decode(code)));

      expect(decodedMap['shade'], 'darkPurple');
      expect(decodedMap['ink'], 'electricViolet');
      expect(decodedMap['grain'], 0.15);
    });
  });

  group('ApiService Configuration Tests', () {
    test('Resolves baseUrl and custom override correctly', () async {
      final initialUrl = ApiService.baseUrl;
      expect(initialUrl.isNotEmpty, true);

      await ApiService.setCustomBaseUrl('https://custom.santori.internal', persist: false);
      expect(ApiService.baseUrl, 'https://custom.santori.internal');

      await ApiService.setCustomBaseUrl('', persist: false);
      expect(ApiService.baseUrl, initialUrl);
    });
  });
}

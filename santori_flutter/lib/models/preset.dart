import '../theme/paper_tokens.dart';

class SavedLookPreset {
  final String name;
  final PaperShade shade;
  final InkColor ink;
  final double grain;
  final bool tilted;
  final VisualizerStyle visualizer;

  const SavedLookPreset({
    required this.name,
    required this.shade,
    required this.ink,
    required this.grain,
    required this.tilted,
    required this.visualizer,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shade': shade.name,
      'ink': ink.name,
      'grain': grain,
      'tilt': tilted ? '1' : '0',
      'visualizer': visualizer.name,
    };
  }

  factory SavedLookPreset.fromJson(Map<String, dynamic> json) {
    PaperShade shade = PaperShade.stone;
    for (var s in PaperShade.values) {
      if (s.name.toLowerCase() == json['shade']?.toString().toLowerCase()) {
        shade = s;
        break;
      }
    }

    InkColor ink = InkColor.blueBlack;
    for (var i in InkColor.values) {
      if (i.name.toLowerCase() == json['ink']?.toString().toLowerCase()) {
        ink = i;
        break;
      }
    }

    VisualizerStyle viz = VisualizerStyle.pencil;
    for (var v in VisualizerStyle.values) {
      if (v.name.toLowerCase() ==
          json['visualizer']?.toString().toLowerCase()) {
        viz = v;
        break;
      }
    }

    double grain = 0.35;
    if (json['grain'] != null) {
      grain = (json['grain'] as num).toDouble();
    }

    bool tilted = json['tilt'] == '1' || json['tilt'] == true;

    return SavedLookPreset(
      name: json['name'] ?? 'Preset',
      shade: shade,
      ink: ink,
      grain: grain,
      tilted: tilted,
      visualizer: viz,
    );
  }
}

import 'package:flutter/material.dart';

enum PaperShade { stone, slate, fog, charcoal, darkPurple, oceanDark }

enum InkColor { blueBlack, graphite, oxblood, pine, electricViolet, neonCyan }

enum VisualizerStyle { pencil, ink, rings, bars }

class ShadeTokens {
  final String name;
  final bool isDark;
  final Color desk;
  final Color paper;
  final Color paper2;
  final Color text;
  final Color muted;
  final Color rule;
  final Color stamp;
  final Color inkShadow;

  const ShadeTokens({
    required this.name,
    required this.isDark,
    required this.desk,
    required this.paper,
    required this.paper2,
    required this.text,
    required this.muted,
    required this.rule,
    required this.stamp,
    required this.inkShadow,
  });
}

class InkTokens {
  final String name;
  final Color lightValue;
  final Color darkValue;

  const InkTokens({
    required this.name,
    required this.lightValue,
    required this.darkValue,
  });
}

class PaperTokens {
  static const Map<PaperShade, ShadeTokens> shades = {
    PaperShade.stone: ShadeTokens(
      name: 'Stone',
      isDark: false,
      desk: Color(0xFFB4B2AD),
      paper: Color(0xFFDEDCD7),
      paper2: Color(0xFFD2D0CA),
      text: Color(0xFF25262A),
      muted: Color(0xFF55565A),
      rule: Color(0xFFB9BCC4),
      stamp: Color(0xFF7A2C35),
      inkShadow: Color(0xFF141C2E),
    ),
    PaperShade.slate: ShadeTokens(
      name: 'Slate',
      isDark: false,
      desk: Color(0xFF9FA1A3),
      paper: Color(0xFFD3D4D4),
      paper2: Color(0xFFC6C7C8),
      text: Color(0xFF25262A),
      muted: Color(0xFF46474B),
      rule: Color(0xFFA4A8B0),
      stamp: Color(0xFF7A2C35),
      inkShadow: Color(0xFF141C2E),
    ),
    PaperShade.fog: ShadeTokens(
      name: 'Fog',
      isDark: false,
      desk: Color(0xFFC3C4C4),
      paper: Color(0xFFE8E8E6),
      paper2: Color(0xFFDCDDDB),
      text: Color(0xFF25262A),
      muted: Color(0xFF55565A),
      rule: Color(0xFFB9BCC4),
      stamp: Color(0xFF7A2C35),
      inkShadow: Color(0xFF141C2E),
    ),
    PaperShade.charcoal: ShadeTokens(
      name: 'Charcoal',
      isDark: true,
      desk: Color(0xFF17181B),
      paper: Color(0xFF2A2C31),
      paper2: Color(0xFF34363C),
      text: Color(0xFFE8E6DF),
      muted: Color(0xFFA9ACB4),
      rule: Color(0xFF464952),
      stamp: Color(0xFFE59AA5),
      inkShadow: Color(0xFF080A10),
    ),
    PaperShade.darkPurple: ShadeTokens(
      name: 'Dark Purple',
      isDark: true,
      desk: Color(0xFF110D1F),
      paper: Color(0xFF1C1533),
      paper2: Color(0xFF261C47),
      text: Color(0xFFF1EDFA),
      muted: Color(0xFFA499C7),
      rule: Color(0xFF3F316B),
      stamp: Color(0xFFE59AA5),
      inkShadow: Color(0xFF06030F),
    ),
    PaperShade.oceanDark: ShadeTokens(
      name: 'Ocean Dark',
      isDark: true,
      desk: Color(0xFF0A151D),
      paper: Color(0xFF10212D),
      paper2: Color(0xFF162D3E),
      text: Color(0xFFE2F1F8),
      muted: Color(0xFF7EA5BC),
      rule: Color(0xFF224259),
      stamp: Color(0xFF8FD1B5),
      inkShadow: Color(0xFF040B10),
    ),
  };

  static const Map<InkColor, InkTokens> inks = {
    InkColor.blueBlack: InkTokens(
      name: 'Blue-black',
      lightValue: Color(0xFF26365A),
      darkValue: Color(0xFF9DB4E8),
    ),
    InkColor.graphite: InkTokens(
      name: 'Graphite',
      lightValue: Color(0xFF3A3D45),
      darkValue: Color(0xFFC9CCD4),
    ),
    InkColor.oxblood: InkTokens(
      name: 'Oxblood',
      lightValue: Color(0xFF6D2A33),
      darkValue: Color(0xFFE59AA5),
    ),
    InkColor.pine: InkTokens(
      name: 'Pine',
      lightValue: Color(0xFF24463A),
      darkValue: Color(0xFF8FD1B5),
    ),
    InkColor.electricViolet: InkTokens(
      name: 'Electric Violet',
      lightValue: Color(0xFF6D28D9),
      darkValue: Color(0xFFC084FC),
    ),
    InkColor.neonCyan: InkTokens(
      name: 'Neon Cyan',
      lightValue: Color(0xFF0369A1),
      darkValue: Color(0xFF38BDF8),
    ),
  };
}

class ListeningProfileData {
  final String id;
  final String name;
  final String description;
  final PaperShade shade;
  final InkColor ink;
  final double grain;
  final bool tilted;
  final VisualizerStyle visualizer;

  const ListeningProfileData({
    required this.id,
    required this.name,
    required this.description,
    required this.shade,
    required this.ink,
    required this.grain,
    required this.tilted,
    required this.visualizer,
  });
}

const List<ListeningProfileData> listeningProfiles = [
  ListeningProfileData(
    id: 'study',
    name: 'Study',
    description: 'Stone + Blue-black + Pencil',
    shade: PaperShade.stone,
    ink: InkColor.blueBlack,
    grain: 0.35,
    tilted: true,
    visualizer: VisualizerStyle.pencil,
  ),
  ListeningProfileData(
    id: 'gym',
    name: 'Gym',
    description: 'Slate + Oxblood + Ink wave',
    shade: PaperShade.slate,
    ink: InkColor.oxblood,
    grain: 0.20,
    tilted: true,
    visualizer: VisualizerStyle.ink,
  ),
  ListeningProfileData(
    id: 'night',
    name: 'Night',
    description: 'Charcoal + Blue-black + Rings',
    shade: PaperShade.charcoal,
    ink: InkColor.blueBlack,
    grain: 0.25,
    tilted: true,
    visualizer: VisualizerStyle.rings,
  ),
  ListeningProfileData(
    id: 'dark-violet',
    name: 'Purple Clay',
    description: 'Dark Purple + Electric Violet',
    shade: PaperShade.darkPurple,
    ink: InkColor.electricViolet,
    grain: 0.15,
    tilted: true,
    visualizer: VisualizerStyle.pencil,
  ),
  ListeningProfileData(
    id: 'ocean-drift',
    name: 'Ocean Glow',
    description: 'Ocean Dark + Neon Cyan + Ink wave',
    shade: PaperShade.oceanDark,
    ink: InkColor.neonCyan,
    grain: 0.15,
    tilted: false,
    visualizer: VisualizerStyle.ink,
  ),
  ListeningProfileData(
    id: 'focus',
    name: 'Focus',
    description: 'Fog + Graphite + Pencil',
    shade: PaperShade.fog,
    ink: InkColor.graphite,
    grain: 0.30,
    tilted: false,
    visualizer: VisualizerStyle.pencil,
  ),
];

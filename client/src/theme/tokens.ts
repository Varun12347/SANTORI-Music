export type PaperShade = 'stone' | 'slate' | 'fog' | 'charcoal' | 'dark-purple' | 'ocean-dark';
export type InkColor = 'blue-black' | 'graphite' | 'oxblood' | 'pine' | 'electric-violet' | 'neon-cyan';
export type VisualizerStyle = 'pencil' | 'ink' | 'rings' | 'bars';
export type TiltMode = '0' | '1';

export interface ShadeTokens {
  name: string;
  isDark: boolean;
  desk: string;
  paper: string;
  paper2: string;
  text: string;
  muted: string;
  rule: string;
  stamp: string;
  hoverTint: string;
}

export interface InkTokens {
  name: string;
  lightValue: string;
  darkValue: string;
}

export const SHADES: Record<PaperShade, ShadeTokens> = {
  'stone': {
    name: 'Stone',
    isDark: false,
    desk: '#b4b2ad',
    paper: '#dedcd7',
    paper2: '#d2d0ca',
    text: '#25262a',
    muted: '#55565a',
    rule: '#b9bcc4',
    stamp: '#7a2c35',
    hoverTint: 'rgba(255, 255, 255, 0.33)',
  },
  'slate': {
    name: 'Slate',
    isDark: false,
    desk: '#9fa1a3',
    paper: '#d3d4d4',
    paper2: '#c6c7c8',
    text: '#25262a',
    muted: '#46474b',
    rule: '#a4a8b0',
    stamp: '#7a2c35',
    hoverTint: 'rgba(255, 255, 255, 0.33)',
  },
  'fog': {
    name: 'Fog',
    isDark: false,
    desk: '#c3c4c4',
    paper: '#e8e8e6',
    paper2: '#dcdddb',
    text: '#25262a',
    muted: '#55565a',
    rule: '#b9bcc4',
    stamp: '#7a2c35',
    hoverTint: 'rgba(255, 255, 255, 0.33)',
  },
  'charcoal': {
    name: 'Charcoal',
    isDark: true,
    desk: '#17181b',
    paper: '#2a2c31',
    paper2: '#34363c',
    text: '#e8e6df',
    muted: '#a9acb4',
    rule: '#464952',
    stamp: '#e59aa5',
    hoverTint: 'rgba(255, 255, 255, 0.07)',
  },
  'dark-purple': {
    name: 'Dark Purple',
    isDark: true,
    desk: '#110d1f',
    paper: '#1c1533',
    paper2: '#261c47',
    text: '#f1edfa',
    muted: '#a499c7',
    rule: '#3f316b',
    stamp: '#e59aa5',
    hoverTint: 'rgba(255, 255, 255, 0.08)',
  },
  'ocean-dark': {
    name: 'Ocean Dark',
    isDark: true,
    desk: '#0a151d',
    paper: '#10212d',
    paper2: '#162d3e',
    text: '#e2f1f8',
    muted: '#7ea5bc',
    rule: '#224259',
    stamp: '#8fd1b5',
    hoverTint: 'rgba(255, 255, 255, 0.08)',
  },
};

export const INKS: Record<InkColor, InkTokens> = {
  'blue-black': {
    name: 'Blue-black',
    lightValue: '#26365a',
    darkValue: '#9db4e8',
  },
  'graphite': {
    name: 'Graphite',
    lightValue: '#3a3d45',
    darkValue: '#c9ccd4',
  },
  'oxblood': {
    name: 'Oxblood',
    lightValue: '#6d2a33',
    darkValue: '#e59aa5',
  },
  'pine': {
    name: 'Pine',
    lightValue: '#24463a',
    darkValue: '#8fd1b5',
  },
  'electric-violet': {
    name: 'Electric Violet',
    lightValue: '#6d28d9',
    darkValue: '#c084fc',
  },
  'neon-cyan': {
    name: 'Neon Cyan',
    lightValue: '#0369a1',
    darkValue: '#38bdf8',
  },
};

export interface ThemeConfig {
  shade: PaperShade;
  ink: InkColor;
  grain: number; // 0 to 0.7
  tilt: TiltMode; // "0" | "1"
  visualizer: VisualizerStyle;
}

export const DEFAULT_THEME: ThemeConfig = {
  shade: 'stone',
  ink: 'blue-black',
  grain: 0.35,
  tilt: '1',
  visualizer: 'pencil',
};

export interface ListeningProfile {
  id: string;
  name: string;
  description: string;
  config: ThemeConfig;
}

export const LISTENING_PROFILES: ListeningProfile[] = [
  {
    id: 'study',
    name: 'Study',
    description: 'Stone + Blue-black + Pencil',
    config: {
      shade: 'stone',
      ink: 'blue-black',
      grain: 0.35,
      tilt: '1',
      visualizer: 'pencil',
    },
  },
  {
    id: 'gym',
    name: 'Gym',
    description: 'Slate + Oxblood + Ink wave',
    config: {
      shade: 'slate',
      ink: 'oxblood',
      grain: 0.20,
      tilt: '1',
      visualizer: 'ink',
    },
  },
  {
    id: 'night',
    name: 'Night',
    description: 'Charcoal + Blue-black + Rings',
    config: {
      shade: 'charcoal',
      ink: 'blue-black',
      grain: 0.25,
      tilt: '1',
      visualizer: 'rings',
    },
  },
  {
    id: 'dark-violet',
    name: 'Purple Clay',
    description: 'Dark Purple + Electric Violet',
    config: {
      shade: 'dark-purple',
      ink: 'electric-violet',
      grain: 0.15,
      tilt: '1',
      visualizer: 'pencil',
    },
  },
  {
    id: 'ocean-drift',
    name: 'Ocean Glow',
    description: 'Ocean Dark + Neon Cyan + Ink wave',
    config: {
      shade: 'ocean-dark',
      ink: 'neon-cyan',
      grain: 0.15,
      tilt: '0',
      visualizer: 'ink',
    },
  },
  {
    id: 'focus',
    name: 'Focus',
    description: 'Fog + Graphite + Pencil',
    config: {
      shade: 'fog',
      ink: 'graphite',
      grain: 0.30,
      tilt: '0',
      visualizer: 'pencil',
    },
  },
];

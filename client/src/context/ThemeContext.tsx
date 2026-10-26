import React, { createContext, useContext, useEffect, useState } from 'react';
import { DEFAULT_THEME, INKS, SHADES } from '../theme/tokens';
import type { InkColor, PaperShade, ThemeConfig, TiltMode, VisualizerStyle } from '../theme/tokens';

export interface SavedPreset {
  name: string;
  config: ThemeConfig;
}

interface ThemeContextType {
  config: ThemeConfig;
  autoShade: boolean;
  sleepTimerMinutes: number | null;
  sleepRemainingSeconds: number | null;
  presets: SavedPreset[];
  setShade: (shade: PaperShade) => void;
  setInk: (ink: InkColor) => void;
  setGrain: (grain: number) => void;
  setTilt: (tilt: TiltMode) => void;
  setVisualizer: (style: VisualizerStyle) => void;
  setAutoShade: (active: boolean) => void;
  setSleepTimer: (minutes: number | null) => void;
  savePreset: (name: string) => boolean;
  applyPreset: (preset: SavedPreset) => void;
  deletePreset: (name: string) => void;
  exportLookCode: () => string;
  importLookCode: (code: string) => { success: boolean; error?: string };
  restoreDefaults: () => void;
  isDark: boolean;
  currentInkValue: string;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

const STORAGE_KEY = 'folio_theme_config';
const PRESETS_KEY = 'folio_presets';
const AUTO_KEY = 'folio_auto_shade';

const ALLOWED_SHADES: PaperShade[] = ['stone', 'slate', 'fog', 'charcoal', 'dark-purple', 'ocean-dark'];
const ALLOWED_INKS: InkColor[] = ['blue-black', 'graphite', 'oxblood', 'pine', 'electric-violet', 'neon-cyan'];
const ALLOWED_VISUALIZERS: VisualizerStyle[] = ['pencil', 'ink', 'rings', 'bars'];

export const ThemeProvider: React.FC<{ children: React.ReactNode; onSleepEnd?: () => void }> = ({
  children,
  onSleepEnd,
}) => {
  const [config, setConfig] = useState<ThemeConfig>(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      if (saved) {
        const parsed = JSON.parse(saved);
        if (ALLOWED_SHADES.includes(parsed.shade) && ALLOWED_INKS.includes(parsed.ink)) {
          return { ...DEFAULT_THEME, ...parsed };
        }
      }
    } catch {
      // Fallback to default
    }
    return DEFAULT_THEME;
  });

  const [autoShade, setAutoShadeState] = useState<boolean>(() => {
    try {
      return localStorage.getItem(AUTO_KEY) === 'true';
    } catch {
      return false;
    }
  });

  const [presets, setPresets] = useState<SavedPreset[]>(() => {
    try {
      const saved = localStorage.getItem(PRESETS_KEY);
      if (saved) return JSON.parse(saved);
    } catch {
      // Fallback
    }
    return [
      { name: 'Study Session', config: { shade: 'stone', ink: 'blue-black', grain: 0.35, tilt: '1', visualizer: 'pencil' } },
      { name: 'Night Glow', config: { shade: 'charcoal', ink: 'blue-black', grain: 0.25, tilt: '1', visualizer: 'rings' } },
      { name: 'Ocean Drift', config: { shade: 'ocean-dark', ink: 'neon-cyan', grain: 0.15, tilt: '0', visualizer: 'ink' } },
      { name: 'Dark Purple', config: { shade: 'dark-purple', ink: 'electric-violet', grain: 0.15, tilt: '1', visualizer: 'pencil' } },
    ];
  });

  const [sleepTimerMinutes, setSleepTimerMinutes] = useState<number | null>(null);
  const [sleepRemainingSeconds, setSleepRemainingSeconds] = useState<number | null>(null);

  // Time-of-day auto shade logic
  useEffect(() => {
    if (!autoShade) return;

    const applyTimeOfDay = () => {
      const hour = new Date().getHours();
      let calculatedShade: PaperShade = 'stone';
      if (hour < 17) {
        calculatedShade = 'stone';
      } else if (hour >= 17 && hour < 21) {
        calculatedShade = 'slate';
      } else {
        calculatedShade = 'charcoal';
      }
      setConfig((prev) => (prev.shade !== calculatedShade ? { ...prev, shade: calculatedShade } : prev));
    };

    applyTimeOfDay();
    const interval = setInterval(applyTimeOfDay, 60000);
    return () => clearInterval(interval);
  }, [autoShade]);

  // Sleep timer countdown
  useEffect(() => {
    if (sleepRemainingSeconds === null) return;
    if (sleepRemainingSeconds <= 0) {
      if (onSleepEnd) onSleepEnd();
      setSleepTimerMinutes(null);
      setSleepRemainingSeconds(null);
      return;
    }

    const timer = setInterval(() => {
      setSleepRemainingSeconds((prev) => (prev !== null ? prev - 1 : null));
    }, 1000);

    return () => clearInterval(timer);
  }, [sleepRemainingSeconds, onSleepEnd]);

  // Apply CSS Variables to Document
  const currentShade = SHADES[config.shade] || SHADES.stone;
  const currentInk = INKS[config.ink] || INKS['blue-black'];
  const inkValue = currentShade.isDark ? currentInk.darkValue : currentInk.lightValue;

  useEffect(() => {
    const root = document.documentElement;
    root.style.setProperty('--color-desk', currentShade.desk);
    root.style.setProperty('--color-paper', currentShade.paper);
    root.style.setProperty('--color-paper2', currentShade.paper2);
    root.style.setProperty('--color-text', currentShade.text);
    root.style.setProperty('--color-muted', currentShade.muted);
    root.style.setProperty('--color-rule', currentShade.rule);
    root.style.setProperty('--color-stamp', currentShade.stamp);
    root.style.setProperty('--hover-tint', currentShade.hoverTint);
    root.style.setProperty('--color-ink', inkValue);
    root.style.setProperty('--color-ink-shadow', currentShade.isDark ? '#080a10' : '#141c2e');

    // Grain opacity: base grain, multiplied by 0.6 on dark paper
    const effectiveGrain = currentShade.isDark ? config.grain * 0.6 : config.grain;
    root.style.setProperty('--grain-opacity', String(effectiveGrain));

    if (currentShade.isDark) {
      document.body.classList.add('is-dark');
    } else {
      document.body.classList.remove('is-dark');
    }

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(config));
    } catch {
      // Ignored
    }
  }, [config, currentShade, currentInk, inkValue]);

  const setShade = (shade: PaperShade) => setConfig((prev) => ({ ...prev, shade }));
  const setInk = (ink: InkColor) => setConfig((prev) => ({ ...prev, ink }));
  const setGrain = (grain: number) => setConfig((prev) => ({ ...prev, grain: Math.max(0, Math.min(0.7, grain)) }));
  const setTilt = (tilt: TiltMode) => setConfig((prev) => ({ ...prev, tilt }));
  const setVisualizer = (visualizer: VisualizerStyle) => setConfig((prev) => ({ ...prev, visualizer }));

  const setAutoShade = (active: boolean) => {
    setAutoShadeState(active);
    try {
      localStorage.setItem(AUTO_KEY, String(active));
    } catch {
      // Ignored
    }
  };

  const setSleepTimer = (minutes: number | null) => {
    setSleepTimerMinutes(minutes);
    setSleepRemainingSeconds(minutes ? minutes * 60 : null);
  };

  const savePreset = (name: string): boolean => {
    const trimmed = name.trim().slice(0, 30);
    if (!trimmed || presets.length >= 8) return false;
    const updated = [...presets.filter((p) => p.name.toLowerCase() !== trimmed.toLowerCase()), { name: trimmed, config }];
    setPresets(updated);
    try {
      localStorage.setItem(PRESETS_KEY, JSON.stringify(updated));
    } catch {
      // Ignored
    }
    return true;
  };

  const applyPreset = (preset: SavedPreset) => {
    setConfig(preset.config);
  };

  const deletePreset = (name: string) => {
    const updated = presets.filter((p) => p.name !== name);
    setPresets(updated);
    try {
      localStorage.setItem(PRESETS_KEY, JSON.stringify(updated));
    } catch {
      // Ignored
    }
  };

  const exportLookCode = (): string => {
    const json = JSON.stringify(config);
    return btoa(json);
  };

  const importLookCode = (code: string): { success: boolean; error?: string } => {
    try {
      const decoded = atob(code.trim());
      const parsed = JSON.parse(decoded);

      if (
        !ALLOWED_SHADES.includes(parsed.shade) ||
        !ALLOWED_INKS.includes(parsed.ink) ||
        !ALLOWED_VISUALIZERS.includes(parsed.visualizer) ||
        typeof parsed.grain !== 'number' ||
        parsed.grain < 0 ||
        parsed.grain > 0.7 ||
        (parsed.tilt !== '0' && parsed.tilt !== '1')
      ) {
        return { success: false, error: 'That code is not valid.' };
      }

      setConfig({
        shade: parsed.shade,
        ink: parsed.ink,
        grain: parsed.grain,
        tilt: parsed.tilt,
        visualizer: parsed.visualizer,
      });
      return { success: true };
    } catch {
      return { success: false, error: 'That code is not valid.' };
    }
  };

  const restoreDefaults = () => {
    setConfig(DEFAULT_THEME);
    setAutoShade(false);
  };

  return (
    <ThemeContext.Provider
      value={{
        config,
        autoShade,
        sleepTimerMinutes,
        sleepRemainingSeconds,
        presets,
        setShade,
        setInk,
        setGrain,
        setTilt,
        setVisualizer,
        setAutoShade,
        setSleepTimer,
        savePreset,
        applyPreset,
        deletePreset,
        exportLookCode,
        importLookCode,
        restoreDefaults,
        isDark: currentShade.isDark,
        currentInkValue: inkValue,
      }}
    >
      {/* Paper Grain Overlay */}
      <div className="paper-grain-overlay" aria-hidden="true" />
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
};

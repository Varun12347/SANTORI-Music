import React, { useEffect, useState } from 'react';
import { Check, Copy, Moon, RotateCcw, Sliders, Trash2, X } from 'lucide-react';
import { useTheme } from '../../context/ThemeContext';
import { INKS, SHADES } from '../../theme/tokens';
import type { InkColor, PaperShade, VisualizerStyle } from '../../theme/tokens';

interface DeskSettingsDrawerProps {
  isOpen: boolean;
  onClose: () => void;
}

export const DeskSettingsDrawer: React.FC<DeskSettingsDrawerProps> = ({ isOpen, onClose }) => {
  const {
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
  } = useTheme();

  const [newPresetName, setNewPresetName] = useState('');
  const [importCodeInput, setImportCodeInput] = useState('');
  const [importStatus, setImportStatus] = useState<string | null>(null);
  const [copyStatus, setCopyStatus] = useState<boolean>(false);

  // Close on Escape key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const handleCopyMine = () => {
    const code = exportLookCode();
    navigator.clipboard.writeText(code).then(() => {
      setCopyStatus(true);
      setTimeout(() => setCopyStatus(false), 2000);
    });
  };

  const handleImportSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const res = importLookCode(importCodeInput);
    if (res.success) {
      setImportStatus('Look imported successfully.');
      setImportCodeInput('');
      setTimeout(() => setImportStatus(null), 3000);
    } else {
      setImportStatus(res.error || 'That code is not valid.');
    }
  };

  const handleSavePreset = (e: React.FormEvent) => {
    e.preventDefault();
    if (newPresetName.trim()) {
      const ok = savePreset(newPresetName);
      if (ok) setNewPresetName('');
    }
  };

  const shadesList: PaperShade[] = ['stone', 'slate', 'fog', 'charcoal', 'dark-purple', 'ocean-dark'];
  const inksList: InkColor[] = ['blue-black', 'graphite', 'oxblood', 'pine', 'electric-violet', 'neon-cyan'];
  const visualizersList: { id: VisualizerStyle; label: string }[] = [
    { id: 'pencil', label: 'Pencil' },
    { id: 'ink', label: 'Ink wave' },
    { id: 'rings', label: 'Rings' },
  ];

  const formatRemaining = (sec: number | null) => {
    if (!sec) return '';
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${m}m ${s < 10 ? '0' : ''}${s}s`;
  };

  return (
    <div className="fixed inset-0 z-50 flex justify-end bg-black/40 backdrop-blur-[2px] transition-opacity">
      {/* Backdrop */}
      <div className="absolute inset-0" onClick={onClose} aria-label="Close drawer" />

      {/* Slide-in Drawer Paper Sheet */}
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Desk settings"
        className="relative w-full max-w-md bg-paper h-full shadow-2xl p-6 overflow-y-auto flex flex-col z-10 border-l border-rule"
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-rule">
          <div className="flex items-center space-x-2">
            <Sliders className="w-5 h-5 text-ink" />
            <h2 className="font-serif font-semibold text-xl text-text">Desk settings</h2>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded hover:bg-black/10 dark:hover:bg-white/10 text-muted"
            title="Close drawer (Esc)"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="space-y-6 py-4 flex-1">
          {/* Paper Shade Swatches */}
          <div>
            <label className="block text-xs font-semibold text-muted uppercase tracking-wider mb-2">
              Paper shade
            </label>
            <div className="grid grid-cols-3 gap-2">
              {shadesList.map((shadeKey) => {
                const s = SHADES[shadeKey];
                const active = config.shade === shadeKey;
                return (
                  <button
                    key={shadeKey}
                    onClick={() => setShade(shadeKey)}
                    className={`flex items-center p-2 rounded-[3px] border transition-all text-xs text-left ${
                      active ? 'border-ink ring-2 ring-ink/30 font-semibold' : 'border-rule/60 hover:border-rule'
                    }`}
                    style={{ backgroundColor: s.paper, color: s.text }}
                  >
                    <span
                      className="w-3.5 h-3.5 rounded-full mr-2 border border-black/20 inline-block"
                      style={{ backgroundColor: s.desk }}
                    />
                    <span className="truncate">{s.name}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Ink Color Swatches */}
          <div>
            <label className="block text-xs font-semibold text-muted uppercase tracking-wider mb-2">
              Ink colour
            </label>
            <div className="grid grid-cols-3 gap-2">
              {inksList.map((inkKey) => {
                const item = INKS[inkKey];
                const active = config.ink === inkKey;
                const isDark = SHADES[config.shade].isDark;
                const val = isDark ? item.darkValue : item.lightValue;
                return (
                  <button
                    key={inkKey}
                    onClick={() => setInk(inkKey)}
                    className={`flex items-center p-2 rounded-[3px] border bg-paper2 transition-all text-xs text-left ${
                      active ? 'border-ink ring-2 ring-ink/30 font-semibold text-ink' : 'border-rule/60 text-text'
                    }`}
                  >
                    <span
                      className="w-3.5 h-3.5 rounded-full mr-2 border border-black/10 inline-block"
                      style={{ backgroundColor: val }}
                    />
                    <span className="truncate">{item.name}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Paper Grain Slider */}
          <div>
            <div className="flex justify-between items-center mb-1 text-xs">
              <span className="font-semibold text-muted uppercase tracking-wider">Paper grain</span>
              <span className="font-mono text-muted">{Math.round(config.grain * 100)}%</span>
            </div>
            <input
              type="range"
              min="0"
              max="0.7"
              step="0.05"
              value={config.grain}
              onChange={(e) => setGrain(parseFloat(e.target.value))}
              className="w-full accent-ink cursor-pointer"
            />
          </div>

          {/* Sheet Tilt & Visualizer Style */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-muted uppercase tracking-wider mb-1.5">
                Sheet layout
              </label>
              <div className="flex space-x-1 p-1 bg-paper2 rounded border border-rule/60">
                <button
                  onClick={() => setTilt('1')}
                  className={`flex-1 py-1 text-xs rounded transition-colors ${
                    config.tilt === '1' ? 'bg-ink text-paper font-semibold' : 'text-text hover:text-ink'
                  }`}
                >
                  Tilted
                </button>
                <button
                  onClick={() => setTilt('0')}
                  className={`flex-1 py-1 text-xs rounded transition-colors ${
                    config.tilt === '0' ? 'bg-ink text-paper font-semibold' : 'text-text hover:text-ink'
                  }`}
                >
                  Straight
                </button>
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-muted uppercase tracking-wider mb-1.5">
                Visualizer style
              </label>
              <select
                value={config.visualizer}
                onChange={(e) => setVisualizer(e.target.value as VisualizerStyle)}
                className="w-full bg-paper2 border border-rule/60 text-xs p-1.5 rounded text-text focus:outline-none focus:ring-1 focus:ring-ink"
              >
                {visualizersList.map((v) => (
                  <option key={v.id} value={v.id}>
                    {v.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Auto Shade by Time of Day */}
          <div className="p-3 bg-paper2 rounded border border-rule/60 space-y-1">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-text">Auto shade by time of day</span>
              <input
                type="checkbox"
                checked={autoShade}
                onChange={(e) => setAutoShade(e.target.checked)}
                className="accent-ink w-4 h-4 cursor-pointer"
              />
            </div>
            <p className="text-[11px] text-muted">
              Uses device clock only: Stone before 17:00, Slate 17:00–21:00, Charcoal after 21:00.
            </p>
          </div>

          {/* Sleep Timer */}
          <div>
            <div className="flex justify-between items-center mb-1 text-xs">
              <span className="font-semibold text-muted uppercase tracking-wider">Sleep timer</span>
              {sleepRemainingSeconds ? (
                <span className="text-xs text-ink font-semibold flex items-center space-x-1">
                  <Moon className="w-3 h-3" />
                  <span>Sleep in {formatRemaining(sleepRemainingSeconds)}</span>
                </span>
              ) : null}
            </div>
            <div className="grid grid-cols-4 gap-2">
              {[null, 15, 30, 60].map((mins) => {
                const active = sleepTimerMinutes === mins;
                return (
                  <button
                    key={String(mins)}
                    onClick={() => setSleepTimer(mins)}
                    className={`py-1.5 text-xs rounded border text-center transition-colors ${
                      active
                        ? 'border-ink bg-ink text-paper font-semibold'
                        : 'border-rule/60 bg-paper2 text-text hover:border-rule'
                    }`}
                  >
                    {mins ? `${mins}m` : 'Off'}
                  </button>
                );
              })}
            </div>
          </div>

          {/* My Presets (Max 8) */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <span className="text-xs font-semibold text-muted uppercase tracking-wider">
                My presets ({presets.length}/8)
              </span>
            </div>

            {presets.length > 0 ? (
              <div className="space-y-1.5 mb-3 max-h-36 overflow-y-auto pr-1">
                {presets.map((p) => (
                  <div
                    key={p.name}
                    className="flex items-center justify-between p-2 rounded bg-paper2 border border-rule/40 text-xs"
                  >
                    <button
                      onClick={() => applyPreset(p)}
                      className="font-medium hover:text-ink hover:underline text-left truncate flex-1"
                    >
                      {p.name}
                    </button>
                    <div className="flex items-center space-x-2 pl-2">
                      <span className="text-[10px] text-muted font-mono">{p.config.shade}</span>
                      <button
                        onClick={() => deletePreset(p.name)}
                        className="p-1 text-muted hover:text-red-500 rounded"
                        title="Delete preset"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            ) : null}

            {presets.length < 8 ? (
              <form onSubmit={handleSavePreset} className="flex space-x-2">
                <input
                  type="text"
                  placeholder="Save current look..."
                  maxLength={30}
                  value={newPresetName}
                  onChange={(e) => setNewPresetName(e.target.value)}
                  className="flex-1 text-xs p-1.5 bg-paper2 border border-rule/60 rounded text-text placeholder:text-muted/60 focus:outline-none focus:ring-1 focus:ring-ink"
                />
                <button
                  type="submit"
                  disabled={!newPresetName.trim()}
                  className="btn-tactile text-xs px-3 py-1.5 disabled:opacity-50"
                >
                  Save
                </button>
              </form>
            ) : (
              <p className="text-[11px] text-muted">Maximum 8 presets saved.</p>
            )}
          </div>

          {/* Share or Import a Look */}
          <div className="p-3 bg-paper2 rounded border border-rule/60 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-text">Share or import look</span>
              <button
                onClick={handleCopyMine}
                className="btn-tactile text-xs px-2.5 py-1 flex items-center space-x-1"
              >
                {copyStatus ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                <span>{copyStatus ? 'Copied' : 'Copy mine'}</span>
              </button>
            </div>

            <form onSubmit={handleImportSubmit} className="space-y-1.5">
              <div className="flex space-x-2">
                <input
                  type="text"
                  placeholder="Paste base64 look code..."
                  value={importCodeInput}
                  onChange={(e) => setImportCodeInput(e.target.value)}
                  className="flex-1 text-xs p-1.5 bg-paper border border-rule/60 rounded text-text placeholder:text-muted/60 focus:outline-none focus:ring-1 focus:ring-ink font-mono"
                />
                <button
                  type="submit"
                  disabled={!importCodeInput.trim()}
                  className="btn-tactile text-xs px-3 py-1.5 disabled:opacity-50"
                >
                  Import
                </button>
              </div>
              {importStatus ? (
                <p
                  className={`text-[11px] font-medium ${
                    importStatus.includes('successfully') ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'
                  }`}
                >
                  {importStatus}
                </p>
              ) : null}
            </form>
          </div>
        </div>

        {/* Footer: Restore Defaults */}
        <div className="pt-4 border-t border-rule flex justify-between items-center">
          <button
            onClick={restoreDefaults}
            className="text-xs text-muted hover:text-ink flex items-center space-x-1"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span>Restore defaults</span>
          </button>
          <button onClick={onClose} className="btn-tactile text-xs px-4 py-1.5">
            Done
          </button>
        </div>
      </div>
    </div>
  );
};

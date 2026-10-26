import { describe, expect, it } from 'vitest';
import type { PaperShade } from '../theme/tokens';

const ALLOWED_SHADES = ['stone', 'slate', 'fog', 'charcoal', 'dark-purple', 'ocean-dark'];
const ALLOWED_INKS = ['blue-black', 'graphite', 'oxblood', 'pine', 'electric-violet', 'neon-cyan'];
const ALLOWED_VISUALIZERS = ['pencil', 'ink', 'rings', 'bars'];

function validateLookCode(code: string): { success: boolean; error?: string } {
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
    return { success: true };
  } catch {
    return { success: false, error: 'That code is not valid.' };
  }
}

function getAutoShade(hour: number): PaperShade {
  if (hour < 17) return 'stone';
  if (hour >= 17 && hour < 21) return 'slate';
  return 'charcoal';
}

describe('Theme Customization and Look-Code Validator', () => {
  it('validates a correct look code exported from defaults', () => {
    const validConfig = {
      shade: 'stone',
      ink: 'blue-black',
      grain: 0.35,
      tilt: '1',
      visualizer: 'pencil',
    };
    const base64 = btoa(JSON.stringify(validConfig));
    const result = validateLookCode(base64);
    expect(result.success).toBe(true);
  });

  it('validates Dark Purple and Ocean Dark themes', () => {
    const purpleConfig = {
      shade: 'dark-purple',
      ink: 'electric-violet',
      grain: 0.15,
      tilt: '1',
      visualizer: 'pencil',
    };
    const base64 = btoa(JSON.stringify(purpleConfig));
    expect(validateLookCode(base64).success).toBe(true);
  });

  it('rejects an invalid shade code', () => {
    const invalidConfig = {
      shade: 'neon-magenta',
      ink: 'blue-black',
      grain: 0.35,
      tilt: '1',
      visualizer: 'pencil',
    };
    const base64 = btoa(JSON.stringify(invalidConfig));
    const result = validateLookCode(base64);
    expect(result.success).toBe(false);
    expect(result.error).toBe('That code is not valid.');
  });

  it('rejects grain out of range (> 0.7)', () => {
    const invalidConfig = {
      shade: 'stone',
      ink: 'blue-black',
      grain: 0.95,
      tilt: '1',
      visualizer: 'pencil',
    };
    const base64 = btoa(JSON.stringify(invalidConfig));
    const result = validateLookCode(base64);
    expect(result.success).toBe(false);
  });

  it('rejects corrupted non-base64 strings', () => {
    const result = validateLookCode('corrupted#string!not-base64');
    expect(result.success).toBe(false);
    expect(result.error).toBe('That code is not valid.');
  });

  it('accurately maps auto-shade by time of day', () => {
    expect(getAutoShade(10)).toBe('stone');
    expect(getAutoShade(16)).toBe('stone');
    expect(getAutoShade(17)).toBe('slate');
    expect(getAutoShade(20)).toBe('slate');
    expect(getAutoShade(21)).toBe('charcoal');
    expect(getAutoShade(23)).toBe('charcoal');
    expect(getAutoShade(2)).toBe('stone');
  });
});

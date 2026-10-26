import React, { useEffect, useRef } from 'react';
import { globalAudioEngine } from '../../audio/synthEngine';
import { renderVisualizer } from '../../audio/visualizerRenderer';
import { useAudio } from '../../context/AudioContext';
import { useTheme } from '../../context/ThemeContext';

interface PaperVisualizerProps {
  className?: string;
  width?: number;
  height?: number;
}

export const PaperVisualizer: React.FC<PaperVisualizerProps> = ({
  className = 'w-full h-16',
  width = 320,
  height = 64,
}) => {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const { isPlaying } = useAudio();
  const { config, currentInkValue } = useTheme();

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animId: number;
    const analyser = globalAudioEngine.getAnalyser();
    const dataArray = analyser ? new Uint8Array(analyser.frequencyBinCount) : new Uint8Array(64);

    const checkReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    const render = () => {
      if (analyser && isPlaying) {
        analyser.getByteFrequencyData(dataArray);
      }
      renderVisualizer(
        ctx,
        canvas.width,
        canvas.height,
        dataArray,
        config.visualizer,
        currentInkValue,
        isPlaying,
        checkReducedMotion
      );
      animId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animId);
    };
  }, [isPlaying, config.visualizer, currentInkValue]);

  return (
    <canvas
      ref={canvasRef}
      width={width}
      height={height}
      className={`rounded ${className}`}
      aria-label="Real-time audio visualizer"
    />
  );
};

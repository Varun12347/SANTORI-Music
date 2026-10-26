import type { VisualizerStyle } from '../theme/tokens';

export function renderVisualizer(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  dataArray: Uint8Array,
  style: VisualizerStyle,
  inkColor: string,
  isPlaying: boolean,
  reducedMotion: boolean
) {
  ctx.clearRect(0, 0, width, height);

  ctx.strokeStyle = inkColor;
  ctx.fillStyle = inkColor;
  ctx.lineWidth = 1.8;
  ctx.lineCap = 'round';
  ctx.lineJoin = 'round';

  const bufferLength = dataArray.length;
  const time = performance.now() * 0.002;

  if (style === 'pencil') {
    // Vertical graphite strokes with slight jitter
    const barWidth = 3;
    const gap = 5;
    const totalBars = Math.floor(width / (barWidth + gap));
    const step = Math.floor(bufferLength / totalBars);

    for (let i = 0; i < totalBars; i++) {
      const dataVal = isPlaying ? dataArray[i * step] : 18 + Math.sin(time + i * 0.3) * 12;
      const barHeight = Math.max(4, (dataVal / 255) * (height * 0.8));
      const x = i * (barWidth + gap) + 4;
      const y1 = (height - barHeight) / 2;
      const y2 = y1 + barHeight;

      const jitter = (!reducedMotion && isPlaying) ? (Math.random() - 0.5) * 1.5 : 0;

      ctx.beginPath();
      ctx.moveTo(x + jitter, y1);
      ctx.lineTo(x - jitter, y2);
      ctx.stroke();
    }
  } else if (style === 'ink') {
    // Single continuous ink wave
    ctx.beginPath();
    const sliceWidth = width / bufferLength;
    let x = 0;

    for (let i = 0; i < bufferLength; i++) {
      let v = dataArray[i] / 128.0;
      if (!isPlaying) {
        v = 1.0 + (reducedMotion ? 0 : Math.sin(time * 1.5 + i * 0.1) * 0.12);
      }
      const y = (v * height) / 2;

      if (i === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
      x += sliceWidth;
    }
    ctx.stroke();
  } else if (style === 'rings') {
    // Concentric wobbly rings
    const centerX = width / 2;
    const centerY = height / 2;
    const maxRadius = Math.min(centerX, centerY) * 0.85;
    const ringCount = 4;

    for (let r = 1; r <= ringCount; r++) {
      const radiusBase = (r / ringCount) * maxRadius;
      ctx.beginPath();

      const numPoints = 32;
      for (let p = 0; p <= numPoints; p++) {
        const angle = (p / numPoints) * Math.PI * 2;
        const dataIdx = Math.floor(((p % numPoints) / numPoints) * (bufferLength / 2));
        const amp = isPlaying ? (dataArray[dataIdx] / 255) * 16 : 3 * Math.sin(time + r);
        const wobble = (!reducedMotion) ? amp : 0;
        const rad = radiusBase + wobble;

        const px = centerX + Math.cos(angle) * rad;
        const py = centerY + Math.sin(angle) * rad;

        if (p === 0) {
          ctx.moveTo(px, py);
        } else {
          ctx.lineTo(px, py);
        }
      }
      ctx.closePath();
      ctx.stroke();
    }
  } else {
    // Fallback: Frequency bars
    const barWidth = Math.max(2, (width / bufferLength) * 2.5);
    let x = 0;
    for (let i = 0; i < bufferLength / 2; i++) {
      const barHeight = ((isPlaying ? dataArray[i] : 20) / 255) * height;
      ctx.fillRect(x, height - barHeight, barWidth - 1, barHeight);
      x += barWidth;
    }
  }
}

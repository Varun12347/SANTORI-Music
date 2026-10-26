// Global Audio Context and Engine for FOLIO & SANTORI Music

class AudioEngine {
  private ctx: AudioContext | null = null;
  private masterGain: GainNode | null = null;
  private analyser: AnalyserNode | null = null;
  private audioElement: HTMLAudioElement | null = null;
  private audioSourceNode: MediaElementAudioSourceNode | null = null;

  // Synthesizer state
  private synthInterval: number | null = null;
  private isSynthPlaying: boolean = false;
  private currentHue: number = 210;
  private currentTempoBpm: number = 95;
  private noteIndex: number = 0;

  constructor() {
    // Initialized lazily on first user interaction
  }

  public init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      this.ctx = new AudioCtx();

      this.masterGain = this.ctx.createGain();
      this.masterGain.gain.value = 0.8;

      this.analyser = this.ctx.createAnalyser();
      this.analyser.fftSize = 256;
      this.analyser.smoothingTimeConstant = 0.82;

      this.masterGain.connect(this.analyser);
      this.analyser.connect(this.ctx.destination);

      // Create internal HTML5 Audio element for real 320kbps streams
      this.audioElement = new Audio();
      this.audioElement.crossOrigin = "anonymous";
      this.audioSourceNode = this.ctx.createMediaElementSource(this.audioElement);
      this.audioSourceNode.connect(this.masterGain);
    }

    if (this.ctx && this.ctx.state === "suspended") {
      this.ctx.resume();
    }
  }

  public getAnalyser(): AnalyserNode | null {
    return this.analyser;
  }

  public getAudioElement(): HTMLAudioElement | null {
    return this.audioElement;
  }

  public setVolume(vol: number) {
    if (this.masterGain && this.ctx) {
      const clamped = Math.max(0, Math.min(1, vol));
      this.masterGain.gain.setTargetAtTime(clamped, this.ctx.currentTime, 0.03);
    }
    if (this.audioElement) {
      this.audioElement.volume = 1; // Handled by masterGain
    }
  }

  public playStream(url: string, startTime: number = 0): Promise<void> {
    this.init();
    this.stopSynth();

    if (!this.audioElement) return Promise.reject("Audio not initialized");

    if (this.audioElement.src !== url) {
      this.audioElement.src = url;
      this.audioElement.currentTime = startTime;
    }
    return this.audioElement.play();
  }

  public pauseStream() {
    if (this.audioElement) {
      this.audioElement.pause();
    }
    this.stopSynth();
  }

  public seekStream(time: number) {
    if (this.audioElement) {
      this.audioElement.currentTime = time;
    }
  }

  // --- Web Audio Demo Synthesizer ---
  // Minor pentatonic intervals: [0, 3, 5, 7, 10, 12, 15, 17]
  public startSynth(hue: number) {
    this.init();
    if (this.audioElement) {
      this.audioElement.pause();
    }

    this.currentHue = hue;
    // Derive base frequency from hue: range ~ 130Hz to 320Hz (C3 to E4)
    const baseFreq = 130 + (hue % 190);
    // Derive tempo from hue: range 75 - 115 BPM
    this.currentTempoBpm = 75 + (hue % 40);
    this.noteIndex = 0;
    this.isSynthPlaying = true;

    if (this.synthInterval) {
      window.clearInterval(this.synthInterval);
    }

    const intervalMs = (60 / this.currentTempoBpm) * 500; // eighth notes
    this.synthInterval = window.setInterval(() => {
      this.triggerSynthNote(baseFreq);
    }, intervalMs);
  }

  public stopSynth() {
    if (this.synthInterval) {
      window.clearInterval(this.synthInterval);
      this.synthInterval = null;
    }
    this.isSynthPlaying = false;
  }

  private triggerSynthNote(baseFreq: number) {
    if (!this.ctx || !this.masterGain || !this.isSynthPlaying) return;

    // Pentatonic scale semitone multipliers
    const pentatonicSemitones = [0, 3, 5, 7, 10, 12, 10, 7, 5, 3, 12, 15];
    const semitone = pentatonicSemitones[this.noteIndex % pentatonicSemitones.length];
    this.noteIndex++;

    const freq = baseFreq * Math.pow(2, semitone / 12);

    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    const filter = this.ctx.createBiquadFilter();

    // Warm paper-style analog tone
    osc.type = this.noteIndex % 3 === 0 ? "triangle" : "sine";
    osc.frequency.setValueAtTime(freq, now);

    // Warm low-pass filter
    filter.type = "lowpass";
    filter.frequency.setValueAtTime(800 + (this.currentHue * 2), now);

    // Short tactile envelope (attack 0.02s, decay 0.28s)
    gain.gain.setValueAtTime(0.0001, now);
    gain.gain.exponentialRampToValueAtTime(0.28, now + 0.02);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.32);

    osc.connect(filter);
    filter.connect(gain);
    gain.connect(this.masterGain);

    osc.start(now);
    osc.stop(now + 0.35);
  }
}

export const globalAudioEngine = new AudioEngine();

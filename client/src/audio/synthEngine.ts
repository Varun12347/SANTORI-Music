// Shared Web Audio analyser and HTML audio stream engine for Santori Music

class AudioEngine {
  private ctx: AudioContext | null = null;
  private masterGain: GainNode | null = null;
  private analyser: AnalyserNode | null = null;
  private audioElement: HTMLAudioElement | null = null;
  private audioSourceNode: MediaElementAudioSourceNode | null = null;

  constructor() {
    // Initialized lazily on first user interaction
  }

  public init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      this.ctx = new AudioCtx();

      this.masterGain = this.ctx.createGain();
      this.masterGain.gain.value = 1;

      this.analyser = this.ctx.createAnalyser();
      this.analyser.fftSize = 256;
      this.analyser.smoothingTimeConstant = 0.82;

      this.masterGain.connect(this.analyser);
      this.analyser.connect(this.ctx.destination);

      this.createAudioSource();
    } else if (!this.audioSourceNode) {
      this.createAudioSource();
    }

    if (this.ctx && this.ctx.state === "suspended") {
      this.ctx.resume();
    }
  }

  public getAnalyser(): AnalyserNode | null {
    return this.analyser;
  }

  public getAudioElement(): HTMLAudioElement | null {
    if (!this.audioElement && typeof Audio !== "undefined") {
      this.audioElement = new Audio();
      this.audioElement.crossOrigin = "anonymous";
    }
    return this.audioElement;
  }

  public setVolume(vol: number) {
    const clamped = Math.max(0, Math.min(1, vol));
    if (this.audioElement) this.audioElement.volume = clamped;
    if (this.masterGain && this.ctx) {
      this.masterGain.gain.setTargetAtTime(1, this.ctx.currentTime, 0.03);
    }
  }

  public playStream(url: string, startTime: number = 0): Promise<void> {
    this.init();

    if (!this.audioElement) return Promise.reject("Audio not initialized");

    if (this.audioElement.src !== url) {
      this.audioElement.src = url;
      this.audioElement.currentTime = startTime;
    } else if (startTime === 0) {
      this.audioElement.currentTime = 0;
    } else {
      this.audioElement.currentTime = startTime;
    }
    return this.audioElement.play();
  }

  public pauseStream() {
    if (this.audioElement) {
      this.audioElement.pause();
    }
  }

  public seekStream(time: number) {
    if (this.audioElement) {
      this.audioElement.currentTime = time;
    }
  }

  private createAudioSource() {
    if (!this.ctx || !this.masterGain || this.audioSourceNode) return;
    this.audioElement = this.getAudioElement();
    if (!this.audioElement) return;
    this.audioSourceNode = this.ctx.createMediaElementSource(this.audioElement);
    this.audioSourceNode.connect(this.masterGain);
  }
}

export const globalAudioEngine = new AudioEngine();

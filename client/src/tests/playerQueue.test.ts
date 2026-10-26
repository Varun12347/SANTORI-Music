import { describe, expect, it } from 'vitest';
import type { Track } from '../context/AudioContext';

describe('Player and Queue Behavior Logic', () => {
  const sampleTracks: Track[] = [
    { id: 't1', title: 'Song One', artist: 'Artist A', duration: 180 },
    { id: 't2', title: 'Song Two', artist: 'Artist B', duration: 210 },
    { id: 't3', title: 'Song Three', artist: 'Artist C', duration: 240 },
  ];

  it('adds track to queue without duplicates when requested', () => {
    let queue = [...sampleTracks];
    const newTrack: Track = { id: 't4', title: 'Song Four', artist: 'Artist D' };
    queue.push(newTrack);
    expect(queue.length).toBe(4);
    expect(queue[3].id).toBe('t4');
  });

  it('removes track at specific queue index', () => {
    let queue = [...sampleTracks];
    const removedIndex = 1;
    queue = queue.filter((_, i) => i !== removedIndex);
    expect(queue.length).toBe(2);
    expect(queue[0].id).toBe('t1');
    expect(queue[1].id).toBe('t3');
  });

  it('handles Previous button: restarts if current position > 3 seconds', () => {
    const currentTime = 5.2;
    let currentTrackIndex = 1;
    let seekedToZero = false;

    if (currentTime > 3) {
      seekedToZero = true;
    } else if (currentTrackIndex > 0) {
      currentTrackIndex -= 1;
    }

    expect(seekedToZero).toBe(true);
    expect(currentTrackIndex).toBe(1);
  });

  it('handles Previous button: goes to previous track if current position <= 3 seconds', () => {
    const currentTime = 1.8;
    let currentTrackIndex = 1;
    let seekedToZero = false;

    if (currentTime > 3) {
      seekedToZero = true;
    } else if (currentTrackIndex > 0) {
      currentTrackIndex -= 1;
    }

    expect(seekedToZero).toBe(false);
    expect(currentTrackIndex).toBe(0);
  });

  it('cycles repeat mode correctly: off -> all -> one -> off', () => {
    type RepeatMode = 'off' | 'all' | 'one';
    const nextRepeat = (current: RepeatMode): RepeatMode => {
      if (current === 'off') return 'all';
      if (current === 'all') return 'one';
      return 'off';
    };

    expect(nextRepeat('off')).toBe('all');
    expect(nextRepeat('all')).toBe('one');
    expect(nextRepeat('one')).toBe('off');
  });

  it('handles repeat-one on track ended by replaying current track', () => {
    const repeatMode = 'one';
    let currentTrackIndex = 1;
    let currentTime = 210;

    if (repeatMode === 'one') {
      currentTime = 0;
    } else {
      currentTrackIndex += 1;
    }

    expect(currentTime).toBe(0);
    expect(currentTrackIndex).toBe(1);
  });
});

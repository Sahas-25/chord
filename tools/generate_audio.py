"""Generates 6 short, original, royalty-free tracks (WAV) with pure Python.
Run:  python tools/generate_audio.py
Because we synthesise the sound ourselves, there is no copyright issue."""
import math, random, wave, os
from array import array

SR = 22050        # samples per second
LENGTH = 30       # seconds per track

# (file, root MIDI note, scale steps, BPM, random seed)
TRACKS = [
    ("track1.wav", 57, [0, 3, 5, 7, 10], 110, 1),
    ("track2.wav", 60, [0, 2, 4, 7, 9], 76, 2),
    ("track3.wav", 55, [0, 2, 4, 5, 7, 9, 11], 96, 3),
    ("track4.wav", 52, [0, 3, 5, 6, 7, 10], 120, 4),
    ("track5.wav", 62, [0, 2, 3, 5, 7, 9, 10], 90, 5),
    ("track6.wav", 58, [0, 2, 4, 7, 9], 104, 6),
]

def freq(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)

def add_note(buf, start, dur, f, vol):
    s, n = int(start * SR), int(dur * SR)
    for i in range(n):
        if s + i >= len(buf):
            break
        t = i / SR
        env = min(1.0, t / 0.01) * math.exp(-2.5 * t / dur) * min(1.0, (n - i) / (0.03 * SR))
        w = (math.sin(2 * math.pi * f * t) + 0.35 * math.sin(4 * math.pi * f * t)
             + 0.15 * math.sin(6 * math.pi * f * t))
        buf[s + i] += vol * env * w

def make_track(name, root, scale, bpm, seed):
    rnd = random.Random(seed)
    beat = 60.0 / bpm
    buf = [0.0] * (LENGTH * SR)
    b = 0
    while b * beat < LENGTH:                      # bass line
        note = root - 12 + scale[(b // 2) % len(scale)]
        add_note(buf, b * beat, beat * 2, freq(note), 0.25)
        b += 2
    idx, pos = 2, 0.0
    while pos < LENGTH:                           # melody
        dur = rnd.choice([0.5, 0.5, 1, 1, 1.5]) * beat
        if rnd.random() > 0.2:
            idx = max(0, min(len(scale) * 2 - 1, idx + rnd.choice([-2, -1, -1, 0, 1, 1, 2])))
            octave, degree = divmod(idx, len(scale))
            add_note(buf, pos, dur * 1.2, freq(root + 12 * octave + scale[degree]), 0.3)
        pos += dur
    fade = SR
    for i in range(fade):                         # fade out last second
        buf[-1 - i] *= i / fade
    peak = max(abs(x) for x in buf) or 1.0
    data = array('h', [int(x / peak * 0.8 * 32767) for x in buf])
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'audio', name)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(data.tobytes())
    print('created', name)

if __name__ == '__main__':
    for t in TRACKS:
        make_track(*t)

#!/usr/bin/env python3
"""Tükenmez'in bütün ses efektlerini ve lo-fi müzik döngülerini sentezler.

Dış kaynak/örnek kullanılmaz; her ses burada matematikle üretilir, bu yüzden
lisans sorunu yoktur. Çıktı: 22.05 kHz, 16 bit mono WAV.

    python3 tools/gen_audio.py            # godot/assets/audio altına yazar
"""
import os
import sys
import wave

import numpy as np

SR = 22050
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "audio")
rng = np.random.default_rng(1905)


# ------------------------------------------------------------------ yardımcılar

def t_axis(dur):
    return np.arange(int(SR * dur)) / SR


def env_adsr(n, a=0.005, d=0.05, s=0.6, r=0.1):
    """Basit ADSR zarfı; n örnek uzunluğunda."""
    a_n, d_n, r_n = int(a * SR), int(d * SR), int(r * SR)
    s_n = max(0, n - a_n - d_n - r_n)
    e = np.concatenate([
        np.linspace(0, 1, max(a_n, 1), endpoint=False),
        np.linspace(1, s, max(d_n, 1), endpoint=False),
        np.full(s_n, s),
        np.linspace(s, 0, max(r_n, 1)),
    ])
    return fit(e, n)


def env_exp(n, tau):
    return np.exp(-np.arange(n) / (SR * tau))


def fit(x, n):
    if len(x) >= n:
        return x[:n]
    return np.concatenate([x, np.zeros(n - len(x))])


def sine(freq, dur, phase=0.0):
    t = t_axis(dur)
    if np.isscalar(freq):
        return np.sin(2 * np.pi * freq * t + phase)
    ph = 2 * np.pi * np.cumsum(fit(np.asarray(freq, float), len(t))) / SR
    return np.sin(ph + phase)


def sweep(f0, f1, dur, curve="exp"):
    n = int(SR * dur)
    if curve == "exp":
        f = f0 * (f1 / f0) ** np.linspace(0, 1, n)
    else:
        f = np.linspace(f0, f1, n)
    return f


def square(freq, dur, duty=0.5):
    t = t_axis(dur)
    ph = (freq * t) % 1.0 if np.isscalar(freq) else (np.cumsum(fit(np.asarray(freq), len(t))) / SR) % 1.0
    # darbe genişliğinden gelen DC bileşeni çıkarılır; sert kenarlar yumuşatılır
    return band(np.where(ph < duty, 1.0, -1.0) - (2 * duty - 1), None, 6000)


def saw(freq, dur):
    t = t_axis(dur)
    ph = (freq * t) % 1.0 if np.isscalar(freq) else (np.cumsum(fit(np.asarray(freq), len(t))) / SR) % 1.0
    return 2.0 * ph - 1.0


def noise(dur):
    return rng.uniform(-1, 1, int(SR * dur))


def band(x, lo=None, hi=None):
    """FFT ile band geçiren süzgeç (yumuşak kenarlı)."""
    n = len(x)
    if n == 0:
        return x
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1 / SR)
    g = np.ones_like(f)
    if lo:
        g *= 1 / (1 + (lo / np.maximum(f, 1e-3)) ** 4)
    if hi:
        g *= 1 / (1 + (f / hi) ** 4)
    return np.fft.irfft(spec * g, n)


def mix(*parts):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def seq(*parts, gap=0.0):
    g = np.zeros(int(SR * gap))
    out = []
    for p in parts:
        out += [p, g]
    return np.concatenate(out)


def at(buf, start_s, x, gain=1.0):
    i = int(start_s * SR)
    if i >= len(buf):
        return
    j = min(len(buf), i + len(x))
    buf[i:j] += x[: j - i] * gain


def soft(x, drive=1.5):
    return np.tanh(x * drive) / np.tanh(drive)


def norm(x, peak=0.9):
    m = np.max(np.abs(x)) if len(x) else 0
    return x if m == 0 else x / m * peak


def fade(x, fin=0.002, fout=0.01):
    x = x.copy()
    a, b = int(fin * SR), int(fout * SR)
    if a:
        x[:a] *= np.linspace(0, 1, a)
    if b:
        x[-b:] *= np.linspace(1, 0, b)
    return x


def write(path, x, peak=0.9):
    x = norm(fade(x), peak)
    data = (np.clip(x, -1, 1) * 32767).astype("<i2").tobytes()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data)


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def bell(freq, dur, tau=0.4):
    n = int(SR * dur)
    partials = [(1, 1.0), (2.76, 0.5), (5.4, 0.25), (8.93, 0.12)]
    x = sum(a * sine(freq * r, dur) * env_exp(n, tau / r ** 0.5) for r, a in partials)
    return x


def pluck(freq, dur, bright=0.5, tau=0.25):
    n = int(SR * dur)
    x = sum((bright ** (k - 1)) / k * sine(freq * k, dur) for k in range(1, 7))
    return x * env_exp(n, tau) * env_adsr(n, 0.003, 0.01, 1.0, 0.02)


# ------------------------------------------------------------------ efektler

def sfx():
    s = {}
    # toplama: kısa "tık" + parlak blip (pitch'i oyunda kombo ile yükselir)
    click = band(noise(0.012), 2000, 8000) * env_exp(int(SR * 0.012), 0.003)
    blip = seq(sine(midi(88), 0.05) * env_exp(int(SR * 0.05), 0.03),
               sine(midi(95), 0.09) * env_exp(int(SR * 0.09), 0.05))
    s["collect"] = mix(click * 0.6, blip * 0.7)
    # büyük toplama: üç notalı arpej
    s["collect_big"] = seq(*[pluck(midi(n), 0.07, 0.6, 0.08) for n in (84, 88, 91)],
                           pluck(midi(96), 0.25, 0.6, 0.12))
    # ekstra kredi: pırıltılı arpej + shimmer
    arp = seq(*[bell(midi(n), 0.06, 0.1) for n in (84, 88, 91, 96, 100)])
    s["bonus"] = mix(arp, band(noise(0.5), 5000, 10000) * env_exp(int(SR * 0.5), 0.15) * 0.15)
    # güçlendirici: yükselen, korolu süpürme
    f = sweep(300, 1200, 0.45)
    s["powerup"] = (sine(f, 0.45) + 0.6 * sine(f * 1.5, 0.45) + 0.3 * square(f * 0.5, 0.45) * 0.3) \
        * env_adsr(int(SR * 0.45), 0.01, 0.1, 0.8, 0.15)
    # çarpışma: pes gümbürtü + kırtlama
    n = int(SR * 0.35)
    thump = sine(sweep(160, 45, 0.35), 0.35) * env_exp(n, 0.09)
    crunch = band(noise(0.35), 300, 3000) * env_exp(n, 0.05)
    s["hit"] = soft(mix(thump * 1.2, crunch * 0.7), 2.0)
    # zıplama: "vuup"
    s["jump"] = sine(sweep(260, 780, 0.18), 0.18) * env_adsr(int(SR * 0.18), 0.005, 0.05, 0.7, 0.08) \
        + 0.2 * band(noise(0.18), 1500, 5000) * env_exp(int(SR * 0.18), 0.04)
    # kayma: alçalan hışırtı
    nz = noise(0.32)
    s["slide"] = np.concatenate([band(nz[: len(nz) // 2], 1500, 5000), band(nz[len(nz) // 2:], 600, 2500)]) \
        * env_adsr(int(SR * 0.32), 0.02, 0.05, 0.7, 0.15)
    # yere iniş
    s["land"] = sine(sweep(120, 60, 0.12), 0.12) * env_exp(int(SR * 0.12), 0.03) \
        + band(noise(0.12), 200, 1200) * env_exp(int(SR * 0.12), 0.02) * 0.5
    # şerit değişimi: hava
    s["lane"] = band(noise(0.11), 900, 4000) * np.hanning(int(SR * 0.11))
    # telefon: "ding-ding"
    s["phone"] = seq(bell(midi(93), 0.12, 0.15), bell(midi(98), 0.3, 0.2))
    # konsol: 8 bit bip-bop
    s["console"] = seq(*[square(midi(n), 0.06, 0.25) * 0.5 for n in (76, 72, 79, 67)])
    # kötü arkadaş: kaydırmalı düdük
    s["friend"] = sine(sweep(1400, 500, 0.35), 0.35) * env_adsr(int(SR * 0.35), 0.02, 0.05, 0.9, 0.08)
    # yastık: horlama "zzz"
    zz = band(noise(0.8), 150, 700) * (0.5 + 0.5 * np.sin(2 * np.pi * 3.2 * t_axis(0.8))) ** 2
    s["pillow"] = zz * env_adsr(int(SR * 0.8), 0.1, 0.1, 0.8, 0.3)
    # dizi: kanal paraziti
    s["tv"] = band(noise(0.5), 800, 9000) * env_adsr(int(SR * 0.5), 0.01, 0.05, 0.8, 0.1) \
        * (0.7 + 0.3 * square(23, 0.5))
    # parti: düdük (vibratolu testere)
    vib = 520 + 25 * np.sin(2 * np.pi * 9 * t_axis(0.55))
    s["party"] = band(saw(vib, 0.55), 300, 3500) * env_adsr(int(SR * 0.55), 0.03, 0.05, 0.9, 0.1)
    # şişe: cam tıngırtısı (inharmonik)
    n = int(SR * 0.5)
    s["bottle"] = sum(a * sine(f, 0.5) * env_exp(n, tau) for f, a, tau in
                      [(2100, 1, 0.18), (3470, 0.6, 0.12), (5230, 0.35, 0.08), (7800, 0.2, 0.05)])
    # kalkan açılır: baloncuk
    s["shield"] = mix(sine(sweep(300, 900, 0.25), 0.25) * env_adsr(int(SR * 0.25), 0.01, 0.05, 0.7, 0.1),
                      bell(midi(91), 0.4, 0.2) * 0.4)
    # kalkan kırılır: cam şangırtısı
    n = int(SR * 0.45)
    s["shield_break"] = band(noise(0.45), 2500, 10000) * env_exp(n, 0.1) \
        + sum(sine(f, 0.45) * env_exp(n, 0.06) * 0.3 for f in (2900, 4100, 5600))
    # mıknatıs: dalgalanan uğultu
    wob = 220 * (1 + 0.1 * np.sin(2 * np.pi * 7 * t_axis(0.5)))
    s["magnet"] = (sine(wob, 0.5) + 0.5 * sine(wob * 2.01, 0.5)) * env_adsr(int(SR * 0.5), 0.05, 0.1, 0.8, 0.2)
    # syllabus: sayfa çevirme
    pg = band(noise(0.28), 700, 6000) * np.abs(np.sin(2 * np.pi * 11 * t_axis(0.28))) \
        * env_adsr(int(SR * 0.28), 0.02, 0.05, 0.8, 0.1)
    s["page"] = pg
    # doğru / yanlış kapı
    s["gate_ok"] = seq(pluck(midi(79), 0.1, 0.6, 0.1), pluck(midi(83), 0.1, 0.6, 0.1),
                       pluck(midi(86), 0.35, 0.6, 0.2))
    s["gate_wrong"] = band(square(110, 0.45, 0.5) + square(116.5, 0.45, 0.5), None, 2000) \
        * env_adsr(int(SR * 0.45), 0.01, 0.05, 0.9, 0.08)
    # yoklama zili ve "Burada!"
    s["rollcall"] = seq(bell(midi(84), 0.2, 0.3), bell(midi(84), 0.5, 0.4), gap=0.05)
    s["rollcall_ok"] = seq(pluck(midi(84), 0.08, 0.7), pluck(midi(91), 0.3, 0.7, 0.18))
    # damga "tak"
    n = int(SR * 0.4)
    s["stamp"] = soft(sine(sweep(110, 40, 0.4), 0.4) * env_exp(n, 0.07) * 1.4
                      + band(noise(0.4), 400, 4000) * env_exp(n, 0.02), 2.5)
    # arayüz tıkı
    s["click"] = mix(sine(1800, 0.03) * env_exp(int(SR * 0.03), 0.006),
                     band(noise(0.02), 3000, 9000) * env_exp(int(SR * 0.02), 0.003) * 0.5)
    # boss: alarm, fırlatma, çarpma, "Ek soru!" (bakır stab)
    s["boss_warn"] = seq(*[square(f, 0.09, 0.5) * 0.5 for f in (880, 660, 880, 660)])
    s["boss_throw"] = band(noise(0.4), 400, 3000) * np.hanning(int(SR * 0.4)) \
        + 0.4 * sine(sweep(900, 300, 0.4), 0.4) * np.hanning(int(SR * 0.4))
    n = int(SR * 0.7)
    s["boss_impact"] = soft(sine(sweep(90, 35, 0.7), 0.7) * env_exp(n, 0.15) * 1.3
                            + band(noise(0.7), 150, 4000) * env_exp(n, 0.08), 2.0)
    chord = sum(band(saw(midi(n) * (1 + d), 0.6), None, 2200) for n in (55, 59, 62, 67) for d in (-0.003, 0.003))
    s["boss_shout"] = chord * env_adsr(int(SR * 0.6), 0.02, 0.1, 0.7, 0.2)
    # türev rampası: "boing"
    bf = 180 * (1 + 0.5 * np.exp(-t_axis(0.5) * 6) * np.sin(2 * np.pi * 14 * t_axis(0.5)))
    s["ramp"] = sine(bf * np.linspace(1, 2.2, int(SR * 0.5)), 0.5) * env_exp(int(SR * 0.5), 0.18)
    # yerçekimi / buz bölgesi girişi
    s["zone"] = mix(sine(sweep(200, 60, 0.6), 0.6) * env_adsr(int(SR * 0.6), 0.05, 0.1, 0.8, 0.2),
                    band(noise(0.6), 3000, 8000) * env_adsr(int(SR * 0.6), 0.2, 0.1, 0.5, 0.2) * 0.3)
    # bug: böcek cıvıltısı
    s["bug"] = square(sweep(1800, 2600, 0.12, "lin"), 0.12, 0.3) * env_adsr(int(SR * 0.12), 0.005, 0.02, 0.7, 0.03) * 0.5
    # grup ödevi arkadaşı gelir / gider
    s["group_on"] = seq(pluck(midi(67), 0.1, 0.5), pluck(midi(62), 0.25, 0.5, 0.15))
    s["group_off"] = seq(pluck(midi(62), 0.1, 0.5), pluck(midi(67), 0.1, 0.5), pluck(midi(74), 0.25, 0.5, 0.15))
    # ofis saati kapısı
    s["office"] = mix(seq(*[bell(midi(n), 0.08, 0.15) for n in (72, 76, 79, 84, 88, 91)]),
                      band(noise(0.6), 4000, 10000) * env_adsr(int(SR * 0.6), 0.1, 0.1, 0.5, 0.3) * 0.2)
    # bitiş fanfarı
    fan = seq(*[pluck(midi(n), 0.11, 0.7, 0.15) for n in (72, 76, 79)])
    tail = sum(pluck(midi(n), 0.9, 0.6, 0.45) for n in (72, 76, 79, 84))
    s["finish"] = np.concatenate([fan, tail])
    # başarısız: üzgün trombon
    tb = []
    for i, n in enumerate((62, 61, 60)):
        tb.append(band(saw(midi(n), 0.3), None, 1500) * env_adsr(int(SR * 0.3), 0.02, 0.05, 0.9, 0.05))
    wah = 1 + 0.03 * np.sin(2 * np.pi * 6 * t_axis(0.8))
    tb.append(band(saw(midi(59) * wah, 0.8), None, 1300) * env_adsr(int(SR * 0.8), 0.02, 0.1, 0.9, 0.3))
    s["fail"] = np.concatenate(tb)
    # başlangıç düdüğü
    s["start"] = mix(sine(2400 * (1 + 0.02 * np.sin(2 * np.pi * 40 * t_axis(0.35))), 0.35),
                     band(noise(0.35), 2000, 5000) * 0.2) * env_adsr(int(SR * 0.35), 0.01, 0.05, 0.9, 0.08)
    # mürekkep azaldı: cızırtı
    cr = np.zeros(int(SR * 0.6))
    for _ in range(40):
        at(cr, rng.uniform(0, 0.58), band(noise(0.008), 2000, 9000) * rng.uniform(0.3, 1.0))
    s["ink_low"] = cr
    return s


def pen_scratch():
    """Koşu boyunca çalan kalem cızırtısı döngüsü (oyunda pitch hızla artar)."""
    dur = 2.0
    base = band(noise(dur), 1800, 6000)
    grain = 0.55 + 0.45 * np.abs(np.sin(2 * np.pi * 7.0 * t_axis(dur))) ** 3
    x = base * grain * 0.5
    # döngü dikişini gizlemek için baş-son çapraz geçiş
    k = int(0.1 * SR)
    x[:k] = x[:k] * np.linspace(0, 1, k) + x[-k:] * np.linspace(1, 0, k)
    return x[:-k]


# ------------------------------------------------------------------- müzik

def drum_kick():
    n = int(SR * 0.4)
    return soft(sine(sweep(120, 42, 0.4), 0.4) * env_exp(n, 0.12) * 1.3, 1.8)


def drum_snare():
    n = int(SR * 0.25)
    return band(noise(0.25), 800, 6000) * env_exp(n, 0.05) * 0.7 + sine(190, 0.25) * env_exp(n, 0.03) * 0.5


def drum_hat(open_=False):
    d = 0.18 if open_ else 0.05
    return band(noise(d), 6000, None) * env_exp(int(SR * d), 0.06 if open_ else 0.012) * 0.35


def rhodes(freq, dur):
    """Elektrik piyano: FM benzeri çan tınısı + tremolo."""
    n = int(SR * dur)
    t = t_axis(dur)
    mod = np.sin(2 * np.pi * freq * t) * 1.2 * env_exp(n, 0.25)
    x = np.sin(2 * np.pi * freq * t + mod) * env_exp(n, 1.4)
    x += 0.3 * np.sin(2 * np.pi * freq * 2.001 * t) * env_exp(n, 0.4)
    trem = 1 + 0.12 * np.sin(2 * np.pi * 4.5 * t)
    return x * trem * env_adsr(n, 0.004, 0.05, 1.0, 0.12)


def vinyl(dur):
    x = band(noise(dur), 400, 3000) * 0.015
    for _ in range(int(dur * 6)):
        at(x, rng.uniform(0, dur - 0.01), band(noise(0.004), 1500, 9000) * rng.uniform(0.05, 0.25))
    return x


def build_track(bpm, bars, chords, bass_pat, drum_pat, swing=0.12, lead=None, lead_gain=0.25,
                chord_gain=0.28, hat_gain=1.0, lowpass=7000):
    beat = 60.0 / bpm
    step = beat / 4
    dur = bars * 4 * beat
    buf = np.zeros(int(SR * dur) + SR)
    kick, snare = drum_kick(), drum_snare()
    hat_c, hat_o = drum_hat(False), drum_hat(True)

    def tpos(bar, s16):
        sw = swing * step if s16 % 2 == 1 else 0.0
        return bar * 4 * beat + s16 * step + sw

    for bar in range(bars):
        ch = chords[bar % len(chords)]
        # akor: vuruş 1'de ve 3'ün "ve"sinde
        for s16, length in ((0, 2.2), (10, 1.4)):
            for k, n in enumerate(ch):
                at(buf, tpos(bar, s16) + k * 0.012, rhodes(midi(n), length * beat), chord_gain / len(ch) * 2.2)
        # bas
        root = ch[0] - 12 if ch[0] >= 48 else ch[0]
        while root > 43:
            root -= 12
        for s16, off, l16 in bass_pat:
            f = midi(root + off)
            n = int(SR * l16 * step)
            b = (sine(f, l16 * step) + 0.25 * sine(f * 2, l16 * step)) * env_adsr(n, 0.005, 0.05, 0.8, 0.06)
            at(buf, tpos(bar, s16), soft(b, 1.4), 0.5)
        # davul
        for s16, kind in drum_pat:
            if kind == "k":
                at(buf, tpos(bar, s16), kick, 0.9)
            elif kind == "s":
                at(buf, tpos(bar, s16), snare, 0.55)
            elif kind == "h":
                at(buf, tpos(bar, s16), hat_c, 0.8 * hat_gain * rng.uniform(0.7, 1.0))
            elif kind == "o":
                at(buf, tpos(bar, s16), hat_o, 0.6 * hat_gain)
        if lead:
            for s16, n, l16 in lead[bar % len(lead)]:
                at(buf, tpos(bar, s16), pluck(midi(n), l16 * step, 0.45, 0.22), lead_gain)
    # döngü: kuyruğu başa ekle (kesintisiz loop)
    n = int(SR * dur)
    buf[: len(buf) - n] += buf[n:]
    buf = buf[:n]
    buf += vinyl(dur)
    return soft(band(buf, 35, lowpass), 1.2)


def music():
    m = {}
    # lo-fi: Dm9 – G13 – Cmaj9 – Am9
    chords = [[50, 53, 57, 60, 64], [43, 53, 57, 59, 64], [48, 52, 55, 59, 62], [45, 48, 52, 55, 59]]
    bass = [(0, 0, 3), (6, 0, 1), (7, 7, 2), (10, 0, 3), (14, 12, 2)]
    drums = [(0, "k"), (7, "k"), (10, "k"), (4, "s"), (12, "s")] + [(i, "h") for i in range(0, 16, 2)] + [(15, "o")]
    lead = [
        [(0, 72, 3), (4, 74, 2), (6, 77, 4), (12, 76, 4)],
        [(2, 74, 2), (4, 71, 4), (10, 69, 2), (12, 67, 4)],
        [(0, 76, 2), (2, 79, 4), (8, 76, 2), (10, 74, 2), (12, 72, 4)],
        [(4, 72, 2), (6, 69, 6), (14, 67, 2)],
    ]
    m["lofi_base"] = build_track(84, 8, chords, bass, drums)
    # katman: aynı uzunlukta melodi (oyunda ilerleme ile açılır)
    m["lofi_lead"] = lead_layer(84, 8, lead)
    # final: daha hızlı, minör, gerilimli
    fchords = [[45, 48, 52, 55, 60], [41, 45, 48, 52, 57], [43, 47, 50, 53, 57], [40, 44, 47, 50, 56]]
    fbass = [(0, 0, 2), (3, 0, 1), (6, 12, 1), (8, 0, 2), (11, 0, 1), (14, 7, 2)]
    fdrums = [(0, "k"), (6, "k"), (8, "k"), (11, "k"), (4, "s"), (12, "s"), (15, "s")] + \
        [(i, "h") for i in range(16)] + [(6, "o"), (14, "o")]
    m["final_base"] = build_track(104, 8, fchords, fbass, fdrums, swing=0.05, hat_gain=0.8, chord_gain=0.3)
    # menü: yalnızca akor + vinil, sakin
    m["menu"] = build_track(72, 8, chords, [(0, 0, 8), (8, 7, 8)], [(0, "k"), (8, "k"), (4, "s"), (12, "s")]
                            + [(i, "h") for i in range(0, 16, 4)], swing=0.15, chord_gain=0.32, hat_gain=0.6,
                            lowpass=4000)
    return m


def lead_layer(bpm, bars, lead):
    beat = 60.0 / bpm
    step = beat / 4
    dur = bars * 4 * beat
    buf = np.zeros(int(SR * dur) + SR)
    for bar in range(bars):
        for s16, n, l16 in lead[bar % len(lead)]:
            sw = 0.12 * step if s16 % 2 == 1 else 0.0
            at(buf, bar * 4 * beat + s16 * step + sw, pluck(midi(n), l16 * step + 0.3, 0.45, 0.25), 0.6)
            at(buf, bar * 4 * beat + s16 * step + sw + 3 * step, pluck(midi(n), l16 * step, 0.3, 0.2), 0.15)
    n = int(SR * dur)
    buf[: len(buf) - n] += buf[n:]
    return band(buf[:n], 150, 6000)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else ROOT
    for name, x in sfx().items():
        write(os.path.join(out, "sfx", name + ".wav"), x, 0.85)
    write(os.path.join(out, "sfx", "pen_scratch.wav"), pen_scratch(), 0.6)
    for name, x in music().items():
        write(os.path.join(out, "music", name + ".wav"), x, 0.8)
    print("ok", out)


if __name__ == "__main__":
    main()

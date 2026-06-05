import numpy as np
import sounddevice as sd


def brown_noise(duration=60, sample_rate=44100):
    white = np.random.randn(duration * sample_rate)
    brown = np.cumsum(white)
    brown /= np.max(np.abs(brown))
    return brown


sd.play(brown_noise(), samplerate=44100, blocking=True)

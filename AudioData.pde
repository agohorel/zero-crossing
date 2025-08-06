class AudioData {
  float[] spectrum;
  float[] waveform;
  float[] leftWaveform;
  float[] rightWaveform;
  float volume;
  float volSum;

  AudioData(float[] waveform, float[] spectrum, float[] leftWaveform, float[] rightWaveform, float volume, float volSum) {
    this.waveform = waveform;
    this.leftWaveform = leftWaveform;
    this.rightWaveform = rightWaveform;
    this.spectrum = spectrum;
    this.volume = volume;
    this.volSum = volSum;
  }
}

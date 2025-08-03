class AudioData {
  float[] spectrum;
  float[] waveform;
  float[] leftWaveform;
  float[] rightWaveform;
  float volume;

  AudioData(float[] waveform, float[] spectrum, float[] leftWaveform, float[] rightWaveform, float volume ) {
    this.waveform = waveform;
    this.leftWaveform = leftWaveform;
    this.rightWaveform = rightWaveform;
    this.spectrum = spectrum;
    this.volume = volume;
  }
}

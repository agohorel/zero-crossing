class AudioData {
  float[] spectrum;
  float[] waveform;
  float[] leftWaveform;
  float[] rightWaveform;
  float volume;
  float volSum;
  float bass;
  float mid;
  float high;

  AudioData(
    float[] waveform,
    float[] spectrum,
    float[] leftWaveform,
    float[] rightWaveform,
    float volume,
    float volSum,
    float bass,
    float mid,
    float high
    ) {
    this.waveform = waveform;
    this.leftWaveform = leftWaveform;
    this.rightWaveform = rightWaveform;
    this.spectrum = spectrum;
    this.volume = volume;
    this.volSum = volSum;
    this.bass = bass;
    this.mid = mid;
    this.high = high;
  }
}

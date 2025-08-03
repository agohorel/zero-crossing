class AudioData {
 float[] waveform;
 float [] spectrum;
 float volume;
 
  AudioData(float[] waveform, float[] spectrum, float volume) {
    this.waveform = waveform;
    this.spectrum = spectrum;
    this.volume = volume;
  }
}

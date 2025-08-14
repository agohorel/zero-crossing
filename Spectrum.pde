class Spectrum extends BaseSketch {
  void setup() {
    noStroke();
  }

  void draw(AudioData audioData) {
    background(processColor(0));
    float _height = (float) height / (audioData.waveform.length - 1);

    for (int i = 0; i < audioData.waveform.length; i++) {
      float y = _height * i;
      int index = constrain(i * 2, 0, audioData.bufferSize-1);
      fill((processColor(audioData.spectrum[index] * index) * (audioData.waveform[i] * 2)));
      rect(0, y, width, _height);
    }
  }

  void cleanup() {
  }
}

class Ikeda implements Sketch {
  int waveformPoints;
  float bandWidth;

  void setup() {
  }

  void draw(AudioData audioData) {
    background(0);
    waveformPoints = audioData.waveform.length;
    bandWidth = float(displayWidth) / waveformPoints;

    for (int i = 0; i < waveformPoints; i++) {
      float x = i * bandWidth;
      float amp = audioData.waveform[i];
      float brightness = map(amp, 0, 1, 0, 255);

      stroke(brightness);
      line(x, 0, x, height);
    }
  }

  void cleanup() {
  }

  String name() {
    return "Ikeda";
  }
}

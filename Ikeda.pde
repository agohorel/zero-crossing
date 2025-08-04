class Ikeda implements Sketch {
  int waveformPoints;
  float bandWidth;

  @Override
    public Intensity getIntensity() {
    return Intensity.HIGH;
  }


  void setup() {
  }

  void draw(AudioData audioData) {
    background(0);
    waveformPoints = audioData.waveform.length;
    bandWidth = float(displayWidth) / waveformPoints;

    // left channel
    for (int i = 0; i < waveformPoints; i++) {
      float x = i * bandWidth;
      float amp = audioData.leftWaveform[i];
      float brightness = map(amp, 0, 1, 0, 255);

      stroke(brightness);
      line(x, 0, x, height * 0.5);
    }

    for (int i = 0; i < waveformPoints; i++) {
      float x = i * bandWidth;
      float amp = audioData.rightWaveform[i];
      float brightness = map(amp, 0, 1, 0, 255);

      stroke(brightness);
      line(x, height * 0.5, x, height);
    }
  }

  void cleanup() {
  }

  String name() {
    return "Ikeda";
  }
}

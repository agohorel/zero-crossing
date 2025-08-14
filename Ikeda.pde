class Ikeda extends BaseSketch {
  void setup() {
    if (invertColors) {
      strokeWeight(6);
    }
  }

  void draw(AudioData audioData) {
    background(processColor(0));
    int waveformPoints = audioData.waveform.length;
    float bandWidth = float(displayWidth) / waveformPoints;

    // left channel
    for (int i = 0; i < waveformPoints; i++) {
      float x = i * bandWidth;
      float amp = audioData.leftWaveform[i];
      float brightness = map(amp, 0, 1, 0, 255);

      stroke(processColor(brightness));
      line(x, 0, x, height * 0.5);
    }

    for (int i = 0; i < waveformPoints; i++) {
      float x = i * bandWidth;
      float amp = audioData.rightWaveform[i];
      float brightness = map(amp, 0, 1, 0, 255);

      stroke(processColor(brightness));
      line(x, height * 0.5, x, height);
    }
  }

  void cleanup() {
    strokeWeight(1);
  }
}

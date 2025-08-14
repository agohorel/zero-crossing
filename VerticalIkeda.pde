class VerticalIkeda extends BaseSketch {
  void setup() {
    if (invertColors) {
      strokeWeight(6);
    }
  }

  void draw(AudioData audioData) {
    background(processColor(0));
    int waveformPoints = audioData.waveform.length;

    float bandHeight = float(height) / waveformPoints;

    // Left channel (left half of the screen)
    for (int i = 0; i < waveformPoints; i++) {
      float y = i * bandHeight;
      float amp = audioData.leftWaveform[i];
      float brightness = map(amp, 0, 1, 0, 255);

      stroke(processColor(brightness));
      line(0, y, width * 0.5, y);
    }

    // Right channel (right half of the screen)
    for (int i = 0; i < waveformPoints; i++) {
      float y = i * bandHeight;
      float amp = audioData.rightWaveform[i];
      float brightness = map(amp, 0, 1, 0, 255);

      stroke(processColor(brightness));
      line(width * 0.5, y, width, y);
    }
  }

  void cleanup() {
    strokeWeight(1);
  }
}

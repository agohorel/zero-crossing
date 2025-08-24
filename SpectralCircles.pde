class SpectralCircles extends BaseSketch {
  final float middleX = width * 0.5;
  final float middleY = height * 0.5;

  void setup() {
    background(processColor(0));
  }

  void draw(AudioData audioData) {
    fill(processColor(0));
    rect(0, 0, width, height);

    noFill();
    for (int i = 0; i < audioData.spectrum.length; i++) {
      float size = audioData.spectrum[i] * width;
      stroke(processColor(audioData.spectrum[i] * 300));
      ellipse(middleX, middleY, size, size);
    }
  }

  void cleanup() {
  }
}

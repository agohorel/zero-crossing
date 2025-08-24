class CircularEraser extends BaseSketch {
  float size = 0;
  float smoothedSize = 0;

  void setup() {
  }

  void draw(AudioData audioData) {
    background(processColor(255));
    fill(processColor(0));
    size = oscillate(audioData.volSum * 0.1, 0, width);
    smoothedSize = smooth(smoothedSize, size, 0.9);
    ellipse(width * 0.5, height * 0.5, smoothedSize, smoothedSize);
  }

  void cleanup() {
  }
}

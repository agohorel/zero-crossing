class Vectorscope extends BaseSketch {
  float scale = width * 0.67;
  PVector center;

  void setup() {
    center = new PVector(width / 2, height / 2);
  }

  void draw(AudioData audioData) {
    background(processColor(0));

    pushMatrix();
    translate(center.x, center.y);
    rotate(radians(135));

    stroke(processColor(20 + audioData.volume * 400));

    for (int i = 0; i < audioData.bufferSize; i++) {
      float left = audioData.leftWaveform[i] * scale;
      float right = audioData.rightWaveform[i] * scale;

      strokeWeight(1.5);
      point(left * 1.5, right * 1.5);
      point(right * 1.5, left * 1.5);

      strokeWeight(2);
      point(left * 1.2, right * 1.2);
      point(right * 1.2, left * 1.2);

      strokeWeight(4);
      point(left, right);
      point(right, left);
    }

    popMatrix();
  }

  void cleanup() {
    strokeWeight(1);
  }
}

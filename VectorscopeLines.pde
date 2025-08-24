class VectorscopeLines extends BaseSketch {
  float scale = height * 0.67;

  boolean shouldFill = random(1) < 0.25;
  PVector center;


  void setup() {
    center = new PVector(width / 2, height / 2);
    if (!shouldFill) {
      noFill();
    }
    strokeWeight(1);
  }

  void draw(AudioData audioData) {
    background(processColor(0));

    if (shouldFill) {
      fill(processColor(255), audioData.volume * 100);
    }

    pushMatrix();
    translate(center.x, center.y);
    rotate(radians(45));

    stroke(processColor(40 + audioData.volume * 400));

    float dynamicScale = scale * (0.5 + audioData.volume * 5);

    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < audioData.bufferSize; i+=4) {
      float left  = audioData.leftWaveform[i] * dynamicScale;
      float right = audioData.rightWaveform[i] * dynamicScale;

      vertex(left, right);
    }
    endShape(CLOSE);

    popMatrix();
  }

  void cleanup() {
  }
}

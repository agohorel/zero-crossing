class CircularWaveform extends BaseSketch {
  float centerX = width / 2;
  float centerY = height / 2;
  float baseRadius = height * 0.34;
  float amplitudeScale = 400;

  void setup() {
    strokeWeight(2);
  }

  void draw(AudioData audioData) {
    noStroke();
    fill(processColor(0), 20);
    rect(0, 0, width, height);


    stroke(processColor(255));
    beginShape();
    for (int i = 0; i < audioData.waveform.length; i++) {
      float angle = map(i, 0, audioData.waveform.length, 0, TWO_PI);
      float amplitude = audioData.waveform[i]; // range is usually -1..1
      float r = baseRadius + amplitude * amplitudeScale;

      float x = centerX + cos(angle) * r;
      float y = centerY + sin(angle) * r;

      vertex(x, y);
    }

    endShape(CLOSE);
  }

  void cleanup() {
    strokeWeight(1);
  }
}

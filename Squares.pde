class Squares extends BaseSketch {
  float smoothed = 0.2;

  void setup() {
    rectMode(CENTER);
    noFill();
  }

  void draw(AudioData audioData) {
    background(processColor(0));

    translate(width * 0.5, height * 0.5);

    for (int i = 0; i < audioData.waveform.length; i++) {
      smoothed = smooth(smoothed, audioData.waveform[i], 0.0025);
      float size = 50 + smoothed * 2 * width;
      rotate(audioData.volSum * 0.0002 * smoothed);
      stroke(processColor(audioData.volume * 20 + audioData.waveform[i] * 300));
      rect(0, 0, size, size);
    }
  }

  void cleanup() {
    rectMode(CORNER);
  }
}

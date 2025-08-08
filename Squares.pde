class Squares implements Sketch {
  PGraphics buffer;
  float smoothed = 0.2;

  void setup() {
    rectMode(CENTER);
    noFill();
  }

  void draw(AudioData audioData) {
    background(0);

    translate(width * 0.5, height * 0.5);

    for (int i = 0; i < audioData.waveform.length; i++) {
      smoothed = smooth(smoothed, audioData.waveform[i], 0.0025);
      float size = smoothed * 2 * width;
      rotate(audioData.volSum * 0.0002 * smoothed);
      stroke(audioData.waveform[i] * 300);
      rect(0, 0, size, size);
    }
  }

  void cleanup() {
    rectMode(CORNER);
  }
}

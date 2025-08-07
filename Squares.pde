

class Squares implements Sketch {
  PGraphics buffer;

  void setup() {
    rectMode(CENTER);
    noFill();
  }

  void draw(AudioData audioData) {
    background(0);

    translate(width * 0.5, height * 0.5);

    for (int i = 0; i < audioData.waveform.length; i++) {
      float size = audioData.waveform[i] * width;
      rotate(audioData.volSum * 0.0001 * audioData.waveform[i]);
      stroke(audioData.waveform[i] * 255);
      rect(0, 0, size, size);
    }
  }

  void cleanup() {
    rectMode(CORNER);
  }
}

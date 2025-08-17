class PhasedWaveforms extends BaseSketch {
  int numCopies = 5;
  float delay = 5;  // samples of phase shift per copy
  float amp = height * 0.5;   // vertical amplitude

  void setup() {
  }

  void draw(AudioData audioData) {
    background(0);
    noFill();

    translate(0, height/2);

    for (int c = 0; c < numCopies; c++) {
      float offset = c * delay;
      stroke(lerpColor(color(127), color(255), c/(float)numCopies));

      beginShape();
      for (int i = 0; i < audioData.waveform.length; i++) {
        // wrap index with offset
        int idx = (int)((i + offset) % audioData.waveform.length);
        float x = map(i, 0, audioData.waveform.length, 0, width);
        float y = audioData.waveform[idx] * amp;

        // alternate mirroring every other copy
        if (c % 2 == 1) y *= -1;

        vertex(x, y);
      }
      endShape();
    }
  }

  void cleanup() {
  }
}

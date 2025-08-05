enum Intensity {
  LOW, MID, HIGH;
}

interface Sketch {
  void setup();
  void draw(AudioData audioData);
  void cleanup();

  // sketches can optionally declare max runtimes
  default int getMaxRuntime() {
    return 3000;
  }
}

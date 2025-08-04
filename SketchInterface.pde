enum Intensity {
  LOW, MID, HIGH;
}

interface Sketch {
  void setup();
  void draw(AudioData audioData);
  void cleanup();
  String name();

  // sketches can optionally declare max runtimes
  default int getMaxRuntime() {
    return 10000;
  }

  // sketches can optionally declare their intensity for auto-switching
  default Intensity getIntensity() {
    return Intensity.MID;
  }
}

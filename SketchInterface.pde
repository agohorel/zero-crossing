enum Intensity {
  LOW, MID, HIGH;
}

interface Sketch {
  void setup();
  void draw(AudioData audioData);
  void cleanup();

  default int getMinRuntime() {
    return 100;
  }
}

class SomeSketch implements Sketch {
  @Override
    public Intensity getIntensity() {
    return Intensity.MID;
  }

  void setup() {
  }

  void draw(AudioData audioData) {
  }

  void cleanup() {
  }

  String name() {
    return "SketchNameHere";
  }
}

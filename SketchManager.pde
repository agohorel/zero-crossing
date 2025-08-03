class SketchManager {
  Sketch currentSketch;

  void loadSketch(String sketchName) {
    if (currentSketch != null) currentSketch.cleanup();

    if (sketchName.equals("A")) {
      currentSketch = new SketchA();
    } else if (sketchName.equals("B")) {
      //currentSketch = new SketchB();
    } else {
      println("Unknown sketch: " + sketchName);
      return;
    }

    currentSketch.setup();
    println("Loaded sketch: " + currentSketch.name());
  }

  void draw(AudioData audioData) {
    if (currentSketch != null) currentSketch.draw(audioData);
  }
}

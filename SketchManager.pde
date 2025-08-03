import java.util.HashMap;
import java.util.Map;
import java.util.function.Supplier;

class SketchManager {
  Sketch currentSketch;
  Map<String, Supplier<Sketch>> sketchRegistry;

  SketchManager() {
    sketchRegistry = new HashMap<String, Supplier<Sketch>>();
    registerSketches();
  }

  void registerSketches() {
    sketchRegistry.put("Tunnel", () -> new Tunnel());
    sketchRegistry.put("FallingCircles", () -> new FallingCircles());
    sketchRegistry.put("ZoomingSquares", () -> new ZoomingSquares());
    sketchRegistry.put("Ikeda", () -> new Ikeda());
  }

  void loadSketch(String sketchName) {
    if (currentSketch != null) currentSketch.cleanup();

    Supplier<Sketch> constructor = sketchRegistry.get(sketchName);
    if (constructor != null) {
      currentSketch = constructor.get();
      currentSketch.setup();
      println("Loaded sketch: " + currentSketch.name());
    } else {
      println("Unknown sketch: " + sketchName);
    }
  }

  void draw(AudioData audioData) {
    if (currentSketch != null) currentSketch.draw(audioData);
  }
}

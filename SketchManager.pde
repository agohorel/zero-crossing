import java.util.HashMap;
import java.util.Map;
import java.util.function.Supplier;
import java.util.ArrayList;

class SketchManager {
  Sketch currentSketch;
  Map<String, Supplier<Sketch>> sketchRegistry;

  // Auto-switch config
  int globalMaxRuntimeMs = 5000; // in ms
  float jumpSensitivity = 2.50f;  // how many stddevs above mean triggers jump
  int volumeHistorySize = 10;

  float[] volumeHistory = new float[volumeHistorySize];
  int volumeHistoryIndex = 0;
  int currentSketchStartTime = 0;

  SketchManager() {
    sketchRegistry = new HashMap<String, Supplier<Sketch>>();
    registerSketches();
  }

  void registerSketches() {
    sketchRegistry.put("Tunnel", () -> new Tunnel());
    sketchRegistry.put("FallingCircles", () -> new FallingCircles());
    sketchRegistry.put("ZoomingSquares", () -> new ZoomingSquares());
    sketchRegistry.put("Ikeda", () -> new Ikeda());
    sketchRegistry.put("VectorNetwork", () -> new VectorNetwork());
  }

  void loadSketch(String sketchName) {
    if (currentSketch != null) {
      currentSketch.cleanup();
    }

    Supplier<Sketch> constructor = sketchRegistry.get(sketchName);
    if (constructor != null) {
      currentSketch = constructor.get();
      currentSketch.setup();
      currentSketchStartTime = millis();
      clearVolumeHistory();
      println("Loaded sketch: " + currentSketch.name());
    } else {
      println("Unknown sketch: " + sketchName);
    }
  }

  void draw(AudioData audioData) {
    if (currentSketch == null) return;

    currentSketch.draw(audioData);

    // Track volume history
    volumeHistory[volumeHistoryIndex] = audioData.volume;
    volumeHistoryIndex = (volumeHistoryIndex + 1) % volumeHistorySize;

    int elapsed = millis() - currentSketchStartTime;
    int maxRuntime = globalMaxRuntimeMs;

    // Check for per-sketch override
    if (currentSketch instanceof HasMaxRuntime) {
      int overrideMs = ((HasMaxRuntime) currentSketch).maxRuntimeMs();
      if (overrideMs > 0) maxRuntime = overrideMs;
    }

    if (elapsed > maxRuntime) {
      float currentVolume = audioData.volume;
      if (detectJump(currentVolume, volumeHistory, volumeHistorySize, jumpSensitivity)) {
        switchSketchRandomly();
      }
    }
  }

  private void clearVolumeHistory() {
    for (int i = 0; i < volumeHistorySize; i++) {
      volumeHistory[i] = 0;
    }
    volumeHistoryIndex = 0;
  }

  private void switchSketchRandomly() {
    ArrayList<String> candidates = new ArrayList<>();
    for (String key : sketchRegistry.keySet()) {
      if (currentSketch == null || !key.equals(currentSketch.name())) {
        candidates.add(key);
      }
    }
    if (candidates.size() == 0) return;

    String nextKey = candidates.get((int) random(candidates.size()));
    loadSketch(nextKey);
  }

  private boolean detectJump(float currentVolume, float[] history, int size, float sensitivity) {
    // Calculate mean
    float sum = 0;
    for (int i = 0; i < size; i++) {
      sum += history[i];
    }
    float mean = sum / size;

    // Calculate std deviation
    float varianceSum = 0;
    for (int i = 0; i < size; i++) {
      float diff = history[i] - mean;
      varianceSum += diff * diff;
    }
    float stddev = sqrt(varianceSum / size);

    // Return true if currentVolume is greater than mean + sensitivity * stddev
    return currentVolume > mean + sensitivity * stddev;
  }
}

// Optional interface for per-sketch max runtime override
interface HasMaxRuntime {
  int maxRuntimeMs();
}

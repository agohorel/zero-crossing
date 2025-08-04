import java.util.HashMap;
import java.util.Map;
import java.util.function.Supplier;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Queue;

class SketchManager {
  Sketch currentSketch;
  Map<String, Supplier<Sketch>> sketchRegistry;

  // Auto-switch config - see sketch interface for global max runtime
  float jumpSensitivity = 2.5f;
  int volumeHistorySize = 10;
  int recentHistorySize = 3;
  Queue<String> recentSketches = new LinkedList<>();

  float[] volumeHistory = new float[volumeHistorySize];
  float[] deltaHistory = new float[volumeHistorySize];
  int volumeHistoryIndex = 0;
  int deltaHistoryIndex = 0;
  int currentSketchStartTime = 0;

  SketchManager() {
    sketchRegistry = new HashMap<>();
    registerSketches();
  }

  void registerSketches() {
    sketchRegistry.put("Tunnel", () -> new Tunnel());
    sketchRegistry.put("FallingCircles", () -> new FallingCircles());
    sketchRegistry.put("ZoomingSquares", () -> new ZoomingSquares());
    sketchRegistry.put("Ikeda", () -> new Ikeda());
    sketchRegistry.put("VectorNetwork", () -> new VectorNetwork());
    sketchRegistry.put("WaveformGrid", () -> new WaveformGrid());
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

    // Track volume history + delta
    float prevVolume = volumeHistory[(volumeHistoryIndex - 1 + volumeHistorySize) % volumeHistorySize];
    float delta = audioData.volume - prevVolume;
    deltaHistory[deltaHistoryIndex] = delta;
    deltaHistoryIndex = (deltaHistoryIndex + 1) % volumeHistorySize;

    volumeHistory[volumeHistoryIndex] = audioData.volume;
    volumeHistoryIndex = (volumeHistoryIndex + 1) % volumeHistorySize;

    int elapsed = millis() - currentSketchStartTime;
    int maxRuntime = currentSketch.getMaxRuntime();

    if (elapsed > maxRuntime &&
      detectJump(audioData.volume, volumeHistory, volumeHistorySize, jumpSensitivity)) {

      float avgDelta = getAverageDelta();

      Intensity currentIntensity = currentSketch.getIntensity();

      Intensity targetIntensity = currentIntensity;

      // ramp intensity up or down depending on avg. delta and current intensity
      if (avgDelta > 0.01f) {
        if (currentIntensity == Intensity.LOW) targetIntensity = Intensity.MID;
        else if (currentIntensity == Intensity.MID) targetIntensity = Intensity.HIGH;
      } else if (avgDelta < -0.01f) {
        if (currentIntensity == Intensity.HIGH) targetIntensity = Intensity.MID;
        else if (currentIntensity == Intensity.MID) targetIntensity = Intensity.LOW;
      }

      switchSketchWithTargetIntensity(targetIntensity);
    }
  }

  private float getAverageDelta() {
    float sum = 0;
    for (float d : deltaHistory) sum += d;
    return sum / volumeHistorySize;
  }

  private void clearVolumeHistory() {
    for (int i = 0; i < volumeHistorySize; i++) {
      volumeHistory[i] = 0;
      deltaHistory[i] = 0;
    }
    volumeHistoryIndex = 0;
    deltaHistoryIndex = 0;
  }

  private void switchSketchWithTargetIntensity(Intensity target) {
    ArrayList<String> candidates = new ArrayList<>();

    for (String key : sketchRegistry.keySet()) {
      if (currentSketch != null &&
        (key.equals(currentSketch.name()) || recentSketches.contains(key))) continue;

      Supplier<Sketch> constructor = sketchRegistry.get(key);
      Sketch sketch = constructor.get();

      Intensity intensity = sketch.getIntensity();

      if (intensity == target) {
        candidates.add(key);
      }
    }

    // Fallback to any non-recent sketch
    if (candidates.size() == 0) {
      for (String key : sketchRegistry.keySet()) {
        if (currentSketch == null || !key.equals(currentSketch.name())) {
          candidates.add(key);
        }
      }
    }

    if (candidates.size() == 0) return;

    String nextKey = candidates.get((int) random(candidates.size()));
    loadSketch(nextKey);

    recentSketches.add(nextKey);
    if (recentSketches.size() > recentHistorySize) recentSketches.poll();
  }

  private boolean detectJump(float currentVolume, float[] history, int size, float sensitivity) {
    float sum = 0;
    for (int i = 0; i < size; i++) sum += history[i];
    float mean = sum / size;

    float varianceSum = 0;
    for (int i = 0; i < size; i++) {
      float diff = history[i] - mean;
      varianceSum += diff * diff;
    }
    float stddev = sqrt(varianceSum / size);

    return currentVolume > mean + sensitivity * stddev;
  }
}

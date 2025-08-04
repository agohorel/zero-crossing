import java.util.*;
import java.util.function.Supplier;

class SketchManager {
  private Sketch currentSketch;
  private final Map<String, Supplier<Sketch>> sketchRegistry;

  // Auto-switch config
  private static final int VOLUME_HISTORY_SIZE = 10;
  private static final int RECENT_HISTORY_SIZE = 3;
  private float jumpSensitivity = 2.5f;

  private final Queue<String> recentSketches = new LinkedList<>();
  private final float[] volumeHistory = new float[VOLUME_HISTORY_SIZE];
  private final float[] deltaHistory = new float[VOLUME_HISTORY_SIZE];
  private int volumeHistoryIndex = 0;
  private int deltaHistoryIndex = 0;
  private int currentSketchStartTime = 0;


  SketchManager() {
    sketchRegistry = new HashMap<>();
    registerSketches();
  }

  private void registerSketches() {
    sketchRegistry.put("Tunnel", Tunnel::new);
    sketchRegistry.put("FallingCircles", FallingCircles::new);
    sketchRegistry.put("ZoomingSquares", ZoomingSquares::new);
    sketchRegistry.put("Ikeda", Ikeda::new);
    sketchRegistry.put("VectorNetwork", VectorNetwork::new);
    sketchRegistry.put("WaveformGrid", WaveformGrid::new);
  }

  void activateSketch(String sketchName) {
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
    float prevVolume = volumeHistory[(volumeHistoryIndex - 1 + VOLUME_HISTORY_SIZE) % VOLUME_HISTORY_SIZE];
    float delta = audioData.volume - prevVolume;
    deltaHistory[deltaHistoryIndex] = delta;
    deltaHistoryIndex = (deltaHistoryIndex + 1) % VOLUME_HISTORY_SIZE;

    volumeHistory[volumeHistoryIndex] = audioData.volume;
    volumeHistoryIndex = (volumeHistoryIndex + 1) % VOLUME_HISTORY_SIZE;

    int elapsed = millis() - currentSketchStartTime;
    int maxRuntime = currentSketch.getMaxRuntime();

    if (elapsed > maxRuntime &&
      detectJump(audioData.volume, volumeHistory, jumpSensitivity)) {

      float avgDelta = getAverageDelta();
      Intensity currentIntensity = currentSketch.getIntensity();
      Intensity targetIntensity = currentIntensity;

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

  private void switchSketchWithTargetIntensity(Intensity target) {
    List<String> candidates = new ArrayList<>();

    for (Map.Entry<String, Supplier<Sketch>> entry : sketchRegistry.entrySet()) {
      String key = entry.getKey();
      if (isSketchRecentOrCurrent(key)) continue;

      Sketch sketch = entry.getValue().get();
      if (sketch.getIntensity() == target) {
        candidates.add(key);
      }
    }

    // Fallback to any non-recent sketch
    if (candidates.isEmpty()) {
      for (String key : sketchRegistry.keySet()) {
        if (!isSketchRecentOrCurrent(key)) {
          candidates.add(key);
        }
      }
    }

    if (candidates.isEmpty()) return;

    Collections.shuffle(candidates);
    String nextKey = candidates.get(0);
    activateSketch(nextKey);

    recentSketches.add(nextKey);
    if (recentSketches.size() > RECENT_HISTORY_SIZE) recentSketches.poll();
  }

  private boolean detectJump(float currentVolume, float[] history, float sensitivity) {
    float sum = 0;
    for (float v : history) sum += v;
    float mean = sum / history.length;

    float varianceSum = 0;
    for (float v : history) {
      float diff = v - mean;
      varianceSum += diff * diff;
    }

    float stddev = sqrt(varianceSum / history.length);
    return currentVolume > mean + sensitivity * stddev;
  }

  private float getAverageDelta() {
    float sum = 0;
    for (float d : deltaHistory) sum += d;
    return sum / VOLUME_HISTORY_SIZE;
  }

  private void clearVolumeHistory() {
    Arrays.fill(volumeHistory, 0);
    Arrays.fill(deltaHistory, 0);
    volumeHistoryIndex = 0;
    deltaHistoryIndex = 0;
  }

  private boolean isSketchRecentOrCurrent(String name) {
    return currentSketch != null &&
      (name.equals(currentSketch.name()) || recentSketches.contains(name));
  }
}

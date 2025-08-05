import java.util.*;
import java.util.function.Supplier;

private static class SketchMeta {
  final Supplier<Sketch> constructor;
  final Intensity intensity;

  SketchMeta(Supplier<Sketch> constructor, Intensity intensity) {
    this.constructor = constructor;
    this.intensity = intensity;
  }
}

class SketchManager {

  private Sketch currentSketch;
  private String currentSketchName;
  private final Map<String, SketchMeta> sketchRegistry;

  // Auto-switch config
  private static final int VOLUME_HISTORY_SIZE = 10;
  private static final int RECENT_HISTORY_SIZE = 2;
  private float jumpSensitivity = 2.5f;
  private float upwardsSensitivity = 0.0125f;
  private float downwardsSensitivity = -0.02f;

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
    sketchRegistry.put("Tunnel", new SketchMeta(Tunnel::new, Intensity.MID));
    sketchRegistry.put("FallingCircles", new SketchMeta(FallingCircles::new, Intensity.LOW));
    sketchRegistry.put("ZoomingSquares", new SketchMeta(ZoomingSquares::new, Intensity.MID));
    sketchRegistry.put("Ikeda", new SketchMeta(Ikeda::new, Intensity.HIGH));
    sketchRegistry.put("VectorNetwork", new SketchMeta(VectorNetwork::new, Intensity.HIGH));
    sketchRegistry.put("WaveformGrid", new SketchMeta(WaveformGrid::new, Intensity.LOW));
  }

  void activateSketch(String sketchName) {
    if (currentSketch != null) {
      currentSketch.cleanup();
    }

    SketchMeta meta = sketchRegistry.get(sketchName);
    if (meta != null) {
      currentSketch = meta.constructor.get();
      currentSketchName = sketchName;
      currentSketch.setup();
      currentSketchStartTime = millis();
      clearVolumeHistory();
      println("Loaded sketch: " + sketchName);
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
      SketchMeta meta = sketchRegistry.get(currentSketchName);
      if (meta == null) return; // Safety check

      Intensity currentIntensity = meta.intensity;
      Intensity targetIntensity = currentIntensity;

      if (avgDelta > upwardsSensitivity) {
        if (currentIntensity == Intensity.LOW) targetIntensity = Intensity.MID;
        else if (currentIntensity == Intensity.MID) targetIntensity = Intensity.HIGH;
      } else if (avgDelta < downwardsSensitivity) {
        if (currentIntensity == Intensity.HIGH) targetIntensity = Intensity.MID;
        else if (currentIntensity == Intensity.MID) targetIntensity = Intensity.LOW;
      }

      switchSketchWithTargetIntensity(targetIntensity);
    }
  }

  private void switchSketchWithTargetIntensity(Intensity target) {
    List<String> candidates = new ArrayList<>();

    for (Map.Entry<String, SketchMeta> entry : sketchRegistry.entrySet()) {
      String key = entry.getKey();
      if (isSketchRecentOrCurrent(key)) continue;

      if (entry.getValue().intensity == target) {
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
    return abs(currentVolume - mean) > sensitivity * stddev;
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
    return name.equals(currentSketchName) || recentSketches.contains(name);
  }
}

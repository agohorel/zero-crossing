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

  private float LOW_THRESHOLD = 0.075;
  private float MID_THRESHOLD = 0.15;
  private float HIGH_THRESHOLD = 0.2;

  private Sketch currentSketch;
  private String currentSketchName;
  private final Map<String, SketchMeta> sketchRegistry;

  // Auto-switch config
  private static final int VOLUME_HISTORY_SIZE = 10;
  private static final int RECENT_HISTORY_SIZE = 2;
  private float jumpSensitivity = 2.5f;

  private final Queue<String> recentSketches = new LinkedList<>();
  private final float[] volumeHistory = new float[VOLUME_HISTORY_SIZE];
  private int volumeHistoryIndex = 0;
  private int currentSketchStartTime = 0;

  SketchManager() {
    sketchRegistry = new HashMap<>();
    registerSketches();
  }

  private void registerSketches() {
    sketchRegistry.put("Tunnel", new SketchMeta(Tunnel::new, Intensity.MID));
    sketchRegistry.put("FallingCircles", new SketchMeta(FallingCircles::new, Intensity.LOW));
    sketchRegistry.put("ZoomingSquares", new SketchMeta(ZoomingSquares::new, Intensity.LOW));
    sketchRegistry.put("Ikeda", new SketchMeta(Ikeda::new, Intensity.HIGH));
    sketchRegistry.put("VectorNetwork", new SketchMeta(VectorNetwork::new, Intensity.MID));
    sketchRegistry.put("WaveformGrid", new SketchMeta(WaveformGrid::new, Intensity.HIGH));
    sketchRegistry.put("Squares", new SketchMeta(Squares::new, Intensity.HIGH));
    sketchRegistry.put("SpectralCircles", new SketchMeta(SpectralCircles::new, Intensity.HIGH));
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

    volumeHistory[volumeHistoryIndex] = audioData.volume;
    volumeHistoryIndex = (volumeHistoryIndex + 1) % VOLUME_HISTORY_SIZE;

    int elapsed = millis() - currentSketchStartTime;
    int maxRuntime = currentSketch.getMaxRuntime();

    if (elapsed > maxRuntime &&
      detectJump(audioData.volume, volumeHistory, jumpSensitivity)) {

      SketchMeta meta = sketchRegistry.get(currentSketchName);

      Intensity currentIntensity = meta.intensity;
      Intensity targetIntensity = currentIntensity;

      float avgVolHistory = getAverageVolume();
      println("\navg recent volume at switch time", avgVolHistory);

      if (avgVolHistory > HIGH_THRESHOLD) {
        println("targeting high intensity...");
        targetIntensity = Intensity.HIGH;
      } else if (avgVolHistory > MID_THRESHOLD && avgVolHistory < HIGH_THRESHOLD) {
        println("targeting medium intensity...");
        targetIntensity = Intensity.MID;
      } else {
        println("targeting low intensity...");
        targetIntensity = Intensity.LOW;
      }

      switchSketchWithTargetIntensity(targetIntensity);
    }
  }

  private void switchSketchWithTargetIntensity(Intensity target) {
    List<String> candidates = new ArrayList<>();

    // Gather sketches matching the desired intensity
    for (Map.Entry<String, SketchMeta> entry : sketchRegistry.entrySet()) {
      if (entry.getValue().intensity == target) {
        println("adding matching candidates");
        candidates.add(entry.getKey());
      }
    }

    // Fallback to all sketches if none match intensity
    if (candidates.isEmpty()) {
      println("no matching candidates");
      candidates.addAll(sketchRegistry.keySet());
    }

    // Prevent immediately repeating the current sketch
    candidates.remove(currentSketchName);

    // If we removed the only candidate (i.e. current sketch was the only match), exit
    if (candidates.isEmpty()) return;

    // Pick a sketch at random
    Collections.shuffle(candidates);
    String nextKey = candidates.get(0);
    activateSketch(nextKey);
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

  private float getAverageVolume() {
    float sum = 0;
    for (float volFrame : volumeHistory) sum += volFrame;
    return sum / VOLUME_HISTORY_SIZE;
  }

  private void clearVolumeHistory() {
    Arrays.fill(volumeHistory, 0);
    volumeHistoryIndex = 0;
  }

  private boolean isSketchRecentOrCurrent(String name) {
    return name.equals(currentSketchName) || recentSketches.contains(name);
  }
}

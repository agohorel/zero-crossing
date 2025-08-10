import java.util.*;
import java.util.function.Supplier;

class SketchManager {
  private Sketch currentSketch;
  private String currentSketchName;
  private final Map<String, Supplier<Sketch>> sketchRegistry;
  private final String[] sketchKeys; // all sketch names in an array
  private int currentIndex = -1;     // index of current sketch

  // Auto-switch config
  private static final int VOLUME_HISTORY_SIZE = 10;
  private float jumpSensitivity = 2.75f;
  private final float[] volumeHistory = new float[VOLUME_HISTORY_SIZE];
  private int volumeHistoryIndex = 0;
  private int currentSketchStartTime = 0;

  SketchManager() {
    sketchRegistry = new LinkedHashMap<>();
    registerSketches();
    sketchKeys = sketchRegistry.keySet().toArray(new String[0]);
  }

  private void registerSketches() {
    sketchRegistry.put("WhiteSquare", WhiteSquare::new);
    sketchRegistry.put("FallingCircles", FallingCircles::new);
    sketchRegistry.put("ZoomingSquares", ZoomingSquares::new);

    sketchRegistry.put("Tunnel", Tunnel::new);
    sketchRegistry.put("VectorNetwork", VectorNetwork::new);
    sketchRegistry.put("Blob", Blob::new);

    sketchRegistry.put("WaveformGrid", WaveformGrid::new);
    sketchRegistry.put("Ikeda", Ikeda::new);
    sketchRegistry.put("Squares", Squares::new);
    sketchRegistry.put("SpectralCircles", SpectralCircles::new);
    sketchRegistry.put("VerticalIkeda", VerticalIkeda::new);
  }

  void activateSketch(String sketchName) {
    if (currentSketch != null) {
      currentSketch.cleanup();
    }

    Supplier<Sketch> sketch = sketchRegistry.get(sketchName);
    if (sketch != null) {
      currentSketch = sketch.get();
      currentSketch.setup();
      currentSketchStartTime = millis();

      currentSketchName = sketchName;
      // update index
      for (int i = 0; i < sketchKeys.length; i++) {
        if (sketchKeys[i].equals(sketchName)) {
          currentIndex = i;
          break;
        }
      }
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
    int minRuntime = currentSketch.getMinRuntime();

    if (elapsed > minRuntime &&
      detectJump(audioData.volume, volumeHistory, jumpSensitivity)) {
      switchSketch();
    }
  }

  private void switchSketch() {
    // Pick random index that’s NOT the current index
    int size = sketchKeys.length;
    if (size <= 1) return;

    int newIndex = (int) random(size - 1);
    if (newIndex >= currentIndex) {
      newIndex++;
    }

    String nextKey = sketchKeys[newIndex];
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

  private void clearVolumeHistory() {
    Arrays.fill(volumeHistory, 0);
    volumeHistoryIndex = 0;
  }
}

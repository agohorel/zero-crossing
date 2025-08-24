import java.util.*;
import java.util.function.Supplier;

class SketchManager {
  private BaseSketch currentSketch;
  private String currentSketchName;
  private final Map<String, Supplier<BaseSketch>> sketchRegistry;
  private final String[] sketchKeys; // all sketch names in an array
  private int currentIndex = -1;     // index of current sketch

  // Auto-switch config
  private static final int VOLUME_HISTORY_SIZE = 10;
  private float jumpSensitivity = 2.5f;
  private float minJumpMagnitude = 0.075f;  // abs vol change must be greater than this to switch

  private final float[] volumeHistory = new float[VOLUME_HISTORY_SIZE];
  private int volumeHistoryIndex = 0;
  private int currentSketchStartTime = 0;

  private boolean wasLastSketchInverted = true; // start true so 1st sketch is always not inverted - see behavior below

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
    sketchRegistry.put("Vectorscope", Vectorscope::new);
    sketchRegistry.put("Rects", Rects::new);
    sketchRegistry.put("Spectrum", Spectrum::new);
    sketchRegistry.put("CircularWaveform", CircularWaveform::new);
    sketchRegistry.put("VectorscopeLines", VectorscopeLines::new);
    sketchRegistry.put("PhasedWaveforms", PhasedWaveforms::new);
    sketchRegistry.put("WaveformPointCloud", WaveformPointCloud::new);
    sketchRegistry.put("SpectrumPointCloud", SpectrumPointCloud::new);
    sketchRegistry.put("Eraser", Eraser::new);
    sketchRegistry.put("CircularEraser", CircularEraser::new);
  }

  void activateSketch(String sketchName) {
    if (currentSketch != null) {
      currentSketch.cleanup();
    }

    Supplier<BaseSketch> sketch = sketchRegistry.get(sketchName);
    if (sketch != null) {
      currentSketch = sketch.get();
      currentSketch.setup();
      currentSketchStartTime = millis();

      // make sure invert never happens twice in a row
      if (wasLastSketchInverted == true) {
        currentSketch.setInvertFlag(false);
      }
      wasLastSketchInverted = currentSketch.invertColors;

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

    float avgVolHistory = getAverageVolume(volumeHistory);
    float volumeDiff = abs(audioData.volume - avgVolHistory);

    if (elapsed > minRuntime &&
      volumeDiff > minJumpMagnitude &&
      detectJump(audioData.volume, avgVolHistory, jumpSensitivity)) {
      switchSketch();
    }
  }

  private void switchSketch() {
    List<String> keys = new ArrayList<>(Arrays.asList(sketchKeys));
    keys.remove(currentIndex);  // remove current sketch
    Collections.shuffle(keys);
    String nextKey = keys.get(0);
    activateSketch(nextKey);
  }


  private boolean detectJump(float currentVolume, float historyMean, float sensitivity) {
    float varianceSum = 0;
    for (float v : volumeHistory) {
      float diff = v - historyMean;
      varianceSum += diff * diff;
    }

    float stddev = sqrt(varianceSum / VOLUME_HISTORY_SIZE);
    return abs(currentVolume - historyMean) > sensitivity * stddev;
  }

  private void clearVolumeHistory() {
    Arrays.fill(volumeHistory, 0);
    volumeHistoryIndex = 0;
  }

  private float getAverageVolume(float[] history) {
    float sum = 0;
    for (float v : history) sum += v;
    return sum / history.length;
  }
}

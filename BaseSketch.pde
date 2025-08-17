interface Sketch {
  void setup();
  void draw(AudioData audioData);
  void cleanup();

  default int getMinRuntime() {
    return 3000;
  }
}

public abstract class BaseSketch implements Sketch {
  boolean invertColors;
  private final float INVERT_CHANCE = 0.2;
  private final float GAMMA = 2.0f;  // >1 darkens midtones


  BaseSketch() {
    invertColors = random(1) < INVERT_CHANCE;
  }

  float processColor(float c) {
    if (!invertColors) return c;

    float normalized = c / 255.0f;
    float adjusted = pow(1.0f - normalized, GAMMA);
    return adjusted * 255.0f;
  }
}

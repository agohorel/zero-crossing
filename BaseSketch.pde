interface Sketch {
  void setup();
  void draw(AudioData audioData);
  void cleanup();

  default int getMinRuntime() {
    return 1000;
  }
}

public abstract class BaseSketch implements Sketch {
  boolean invertColors;
  private float INVERT_CHANCE = 0.2;
  private float INVERT_DARKNESS_EXAGGERATION = 1.5;

  BaseSketch() {
    invertColors = random(1) < INVERT_CHANCE;
  }

  float processColor(float c) {
    return invertColors ? constrain(255 - (c * INVERT_DARKNESS_EXAGGERATION), 0, 255) : c;
  }
}

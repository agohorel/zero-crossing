class WhiteSquare implements Sketch {
  float baseX, baseY;
  float x, y;
  float offset;
  float offsetMinX, offsetMaxX;
  float offsetMinY, offsetMaxY;
  float size;
  float angle;
  float morphFactor;
  float time;

  void setup() {
    baseX = width * 0.5f;
    baseY = height * 0.5f;
    offset = width * 0.25f;
    x = baseX;
    y = baseY;
    size = 100;
    angle = 0;
    morphFactor = 0;
    time = 0;

    // Precompute offset bounds
    offsetMinX = baseX - offset;
    offsetMaxX = baseX + offset;
    offsetMinY = baseY - offset;
    offsetMaxY = baseY + offset;

    noStroke();
    rectMode(CENTER);
  }

  void draw(AudioData audioData) {
    fill(0, 20);
    rect(baseX, baseY, width, height);

    time = audioData.volSum * 0.125f;

    // Oscillate X and Y around center
    float oscX = oscillate(time, offsetMinX, offsetMaxX);
    float oscY = oscillate(time * 0.4f, offsetMinY, offsetMaxY);


    float jitterFactor = audioData.high * 0.07843f; // 20 / 255 = ~0.07843
    float jitterX = jitterFactor - 10f;
    float jitterY = jitterFactor - 10f;

    // Interpolate position
    x += (oscX + jitterX - x) * 0.1f;
    y += (oscY + jitterY - y) * 0.1f;

    // Size modulation
    float baseSize = oscillate(time * 0.8f, 20f, height);
    morphFactor += (audioData.mid * 0.5f - morphFactor) * 0.1f;
    size = baseSize + morphFactor;

    // Angle update
    angle += audioData.bass * 0.0005f;

    // Draw square
    pushMatrix();
    translate(x, y);
    rotate(angle);
    fill(255);
    rect(0, 0, size, size);
    popMatrix();
  }

  void cleanup() {
    rectMode(CORNER);
  }

  String name() {
    return "ReactiveSquare";
  }
}

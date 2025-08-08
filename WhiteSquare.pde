class WhiteSquare implements Sketch {
  float baseX, baseY;     // Center position
  float x, y;             // Oscillating position
  float offset;           // Offset for oscillating position
  float size;             // Oscillating size
  float angle;            // Rotation
  float morphFactor;      // For subtle morphing
  float time;             // Time tracker for oscillation

  void setup() {
    baseX = width / 2;
    baseY = height / 2;
    offset = width / 4;
    x = baseX;
    y = baseY;
    size = 100;
    angle = 0;
    morphFactor = 0;
    time = 0;
    noStroke();
    rectMode(CENTER);
  }

  void draw(AudioData audioData) {
    fill(0, 10 + audioData.volume * 255);
    rect(baseX, baseY, width, height);

    time = audioData.volSum * 0.125;

    // Oscillate position around center with small amplitude + high freq jitter
    float oscX = oscillate(time, baseX - offset, baseX + offset);
    float oscY = oscillate(time * 0.4, baseY - offset, baseY + offset);
    float jitterX = map(audioData.high, 0, 255, -10, 10);
    float jitterY = map(audioData.high, 0, 255, -10, 10);
    x = lerp(x, oscX + jitterX, 0.1f);
    y = lerp(y, oscY + jitterY, 0.1f);

    // Oscillate size between 80 and 140 and modulate morph by mid freq
    float baseSize = oscillate(time * 0.8f, 20, height);
    morphFactor = lerp(morphFactor, audioData.mid * 0.5f, 0.1f);
    size = baseSize + morphFactor;

    // Rotate by bass amount
    angle += audioData.bass * 0.0005;

    pushMatrix();
    translate(x, y);
    rotate(angle);
    fill(255);
    float finalSize = size + morphFactor;
    rect(0, 0, finalSize, finalSize);
    popMatrix();
  }

  void cleanup() {
    rectMode(CORNER);
  }

  String name() {
    return "ReactiveSquare";
  }
}

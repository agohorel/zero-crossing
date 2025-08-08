final int NUM_CIRCLES = 750;
Circle[] circles;

class FallingCircles implements Sketch {
  void setup() {
    noStroke();

    circles = new Circle[NUM_CIRCLES];
    for (int i = 0; i < NUM_CIRCLES; i++) {
      circles[i] = new Circle();
    }
  }

  void draw(AudioData audioData) {
    background(0);  // disable this for trails

    for (Circle c : circles) {
      c.update(audioData);
    }
  }

  void cleanup() {
  }
}

class Circle {
  float x, y, radius;
  float fallingSpeed;
  float noiseOffsetX, noiseOffsetY, noiseSpeed;

  Circle() {
    this.x = getRandomX();
    this.y = getRandomY();
    this.radius = getRandomSize();

    this.fallingSpeed = random(0.5, 1.5);
    this.noiseOffsetX = random(1000);
    this.noiseOffsetY = random(2000);
    this.noiseSpeed = random(0.002, 0.01);
  }

  void update(AudioData audioData) {
    boundsCheck();

    float noiseX = noise(noiseOffsetX + audioData.volSum * noiseSpeed);
    float horizontalDrift = map(noiseX, 0, 1, -1.5, 1.5);
    x += horizontalDrift;

    x += sin(audioData.volSum * 0.01 + noiseOffsetX) * 0.3;

    float noiseY = noise(noiseOffsetY + audioData.volSum * noiseSpeed);
    float verticalVariation = map(noiseY, 0, 1, -0.3, 0.3);
    fallingSpeed = 0.125 + audioData.volume * 4;
    y += fallingSpeed + verticalVariation;

    fill(255, map(noiseX, 0, 1, 0, 255) * (0.125 + audioData.volume));
    ellipse(x, y, radius, radius);
  }

  void boundsCheck() {
    if (x < -radius || x > width + radius) {
      y = -radius * 3;
      x = getRandomX();
      radius = getRandomSize();
    }

    if (y > height + radius) {
      y = -radius;
      radius = getRandomSize();
    }
  }

  float getRandomX() {
    return random(0, width);
  }

  float getRandomY() {
    return random(0, height);
  }

  float getRandomSize() {
    return random(5, 50);
  }
}

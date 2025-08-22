class FallingCircles extends BaseSketch {
  final int NUM_CIRCLES = 750;
  Circle[] circles;
  final boolean shouldBlur = random(1) < 0.5;

  void setup() {
    noStroke();
    circles = new Circle[NUM_CIRCLES];
    for (int i = 0; i < NUM_CIRCLES; i++) {
      circles[i] = new Circle();
    }
  }

  void draw(AudioData audioData) {
    if (shouldBlur) {
      fill(processColor(0), 5);
      rect(0, 0, width, height);
    } else {
      background(processColor(0));
    }

    for (Circle c : circles) {
      c.update(audioData, this);
    }
  }

  void cleanup() {
  }
}

class Circle {
  float x, y, radius;
  float baseFallingSpeed, fallingRate;
  float noiseOffsetX, noiseOffsetY, noiseSpeed;

  final int MIN_SIZE = 5;
  final int MAX_SIZE = 50;

  Circle() {
    this.x = getRandomX();
    this.y = getRandomY();
    this.radius = getRandomSize();

    baseFallingSpeed = map(radius, MIN_SIZE, MAX_SIZE, 0.2, 2.0);
    fallingRate = map(radius, MIN_SIZE, MAX_SIZE, 1.0, 3.0);

    noiseOffsetX = random(1000);
    noiseOffsetY = random(2000);
    noiseSpeed = random(0.002, 0.01);
  }

  void update(AudioData audioData, BaseSketch sketch) {
    boundsCheck();


    float audioFactorV = map(radius, MIN_SIZE, MAX_SIZE, 1.0, 2.0); // scale audio effect by radius
    float verticalSpeed = baseFallingSpeed + audioData.volume * fallingRate * audioFactorV;
    float noiseY = noise(noiseOffsetY + audioData.volSum * noiseSpeed);
    float verticalVariation = map(noiseY, 0, 1, -0.3, 0.3);
    y += verticalSpeed + verticalVariation;


    float noiseX = noise(noiseOffsetX + audioData.volSum * noiseSpeed);
    float baseDrift = map(radius, MIN_SIZE, MAX_SIZE, 0.2, 2.0);
    float horizontalDrift = map(noiseX, 0, 1, -baseDrift, baseDrift);


    float audioFactorH = map(radius, MIN_SIZE, MAX_SIZE, 0.5, 1.0);
    horizontalDrift += sin(audioData.volSum * 0.05 + noiseOffsetX) * 2.0 * audioFactorH;

    x += horizontalDrift;


    float alpha = map(radius, MIN_SIZE, MAX_SIZE, 50, 255);
    fill(sketch.processColor(255), alpha);
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
    return random(MIN_SIZE, MAX_SIZE);
  }
}

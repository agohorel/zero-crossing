class FallingSquares extends BaseSketch {
  final int NUM_SQUARES = 750;
  Square[] squares;
  final boolean shouldBlur = random(1) < 0.75;

  void setup() {
    noStroke();
    squares = new Square[NUM_SQUARES];
    for (int i = 0; i < NUM_SQUARES; i++) {
      squares[i] = new Square();
    }
  }

  void draw(AudioData audioData) {
    if (shouldBlur) {
      rectMode(CORNER);
      fill(processColor(0), 5);
      rect(0, 0, width, height);
    } else {
      background(processColor(0));
    }

    for (Square s : squares) {
      s.update(audioData, this);
    }
  }

  void cleanup() {
    rectMode(CORNER);
  }
}

class Square {
  float x, y, size;
  float baseFallingSpeed, fallingRate;
  float noiseOffsetX, noiseOffsetY, noiseSpeed;
  float rotation;

  final int MIN_SIZE = 5;
  final int MAX_SIZE = 50;

  Square() {
    this.x = getRandomX();
    this.y = getRandomY();
    this.size = getRandomSize();

    baseFallingSpeed = map(size, MIN_SIZE, MAX_SIZE, 0.2, 2.0);
    fallingRate = map(size, MIN_SIZE, MAX_SIZE, 1.0, 3.0);

    noiseOffsetX = random(1000);
    noiseOffsetY = random(2000);
    noiseSpeed = random(0.002, 0.01);

    rotation = random(TWO_PI);
  }

  void update(AudioData audioData, BaseSketch sketch) {
    boundsCheck();

    // Vertical movement
    float audioFactorV = map(size, MIN_SIZE, MAX_SIZE, 1.0, 2.0);
    float verticalSpeed = baseFallingSpeed + audioData.volume * fallingRate * audioFactorV;
    float noiseY = noise(noiseOffsetY + audioData.volSum * noiseSpeed);
    float verticalVariation = map(noiseY, 0, 1, -0.3, 0.3);
    y += verticalSpeed + verticalVariation;

    // Horizontal movement
    float noiseX = noise(noiseOffsetX + audioData.volSum * noiseSpeed);
    float baseDrift = map(size, MIN_SIZE, MAX_SIZE, 0.2, 2.0);
    float horizontalDrift = map(noiseX, 0, 1, -baseDrift, baseDrift);

    float audioFactorH = map(size, MIN_SIZE, MAX_SIZE, 0.5, 1.0);
    horizontalDrift += sin(audioData.volSum * 0.05 + noiseOffsetX) * 2.0 * audioFactorH;

    x += horizontalDrift;

    rotation = audioData.volSum * 0.1;

    float alpha = map(size, MIN_SIZE, MAX_SIZE, 50, 255);
    fill(sketch.processColor(255), alpha);

    pushMatrix();
    translate(x, y);
    rotate(rotation);
    rectMode(CENTER);
    rect(0, 0, size, size);
    popMatrix();
  }

  void boundsCheck() {
    if (x < -size || x > width + size) {
      y = -size * 3;
      x = getRandomX();
      size = getRandomSize();
      rotation = random(TWO_PI);
    }

    if (y > height + size) {
      y = -size;
      size = getRandomSize();
      rotation = random(TWO_PI);
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

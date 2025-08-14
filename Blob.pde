class Blob extends BaseSketch {
  int points = 50; // smoothness
  float radius = 100; // base size

  float noiseScale = 0.5; // how stretched the noise is
  float noiseSpeed = 0.01; // animation speed

  float smoothed = 0.0;

  float xOscRange = width * 0.25;
  float yOscRange = height * 0.25;

  // lookup tables for precomputed cos/sin values
  float[] cosTable;
  float [] sinTable;

  void setup() {
    cosTable = new float[points];
    sinTable = new float[points];
    for (int i = 0; i < points; i++) {
      float angle = map(i, 0, points, 0, TWO_PI);
      cosTable[i] = cos(angle);
      sinTable[i] = sin(angle);
    }
  }

  void draw(AudioData audioData) {
    background(processColor(0));
    fill(processColor(255));

    smoothed = smooth(smoothed, audioData.volume * width * 1.75, 0.01);

    float xOsc = oscillate(audioData.volSum * 0.1, -xOscRange, xOscRange);
    float yOsc = oscillate(audioData.volSum * 0.03, -yOscRange, yOscRange);

    translate(xOsc, yOsc);
    drawBlob(smoothed, audioData);
  }

  void drawBlob(float baseRadius, AudioData audioData) {
    beginShape();
    float speed = audioData.volSum * 0.25;
    for (int i = 0; i < points; i++) {
      float xOff = cosTable[i];
      float yOff = sinTable[i];

      // distort
      float noiseVal = noise(xOff * noiseScale + speed,
        yOff * noiseScale + speed);

      // map noise to a radius offset, modulated by audio
      float radius = baseRadius + map(noiseVal, 0, 1, -20, 20) * (1 + audioData.volume * 20);

      float x = width * 0.5f + radius * xOff;
      float y = height * 0.5f + radius * yOff;

      vertex(x, y);
    }
    endShape(CLOSE);
  }


  void cleanup() {
  }
}

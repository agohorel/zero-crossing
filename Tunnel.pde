class Tunnel implements Sketch {
  int numCircles = 50;
  int buffer = 250;

  void setup() {
    noFill();
    stroke(255);
  }

  void draw(AudioData audioData) {
    background(0);

    float centerX = width * 0.5;
    float centerY = height * 0.5;

    for (int i = 0; i < numCircles; i++) {
      stroke(50 + i * 4, map(audioData.volume, 0, 1, 0, 255));

      float size = (pow(i, 2) + frameCount * 2) % (width + buffer);

      // silly hack bc strokeWeight is unbearably slow in processing
      int strokeLayers = int(1 + i * 0.5);
      for (int s = 0; s < strokeLayers; s++) {
        ellipse(centerX, centerY, size + s, size + s);
      }


      ellipse(
        centerX,
        centerY,
        size,
        size
        );
    }
  }

  void cleanup() {
  }
}

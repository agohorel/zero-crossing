class VectorNetwork implements Sketch {
  class Point {
    PVector pos, vel;

    Point() {
      pos = new PVector(random(width), random(height));
      vel = PVector.random2D();
      vel.mult(random(0.5f, 1.5f));
    }

    void update(float speedScale) {
      PVector delta = PVector.mult(vel, speedScale);
      pos.add(delta);

      // Bounce off edges
      if (pos.x < 0 || pos.x > width) vel.x *= -1;
      if (pos.y < 0 || pos.y > height) vel.y *= -1;

      // Clamp position within window
      pos.x = constrain(pos.x, 0, width);
      pos.y = constrain(pos.y, 0, height);
    }
  }

  Point[] points;
  int numPoints = 160;
  float connectionDist = 200;

  void setup() {
    points = new Point[numPoints];
    for (int i = 0; i < numPoints; i++) {
      points[i] = new Point();
    }
    stroke(255);
    strokeWeight(1);
    fill(255);
  }

  void draw(AudioData audioData) {
    background(0);

    // Volume scales speed and line opacity (clamped & smoothed as needed)
    float volumeScale = constrain(audioData.volume * 10, 0.5f, 3);

    // Update points
    for (Point p : points) {
      p.update(volumeScale);
      ellipse(p.pos.x, p.pos.y, 4, 4);
    }

    // Draw connections
    for (int i = 0; i < numPoints; i++) {
      for (int j = i + 1; j < numPoints; j++) {
        float d = PVector.dist(points[i].pos, points[j].pos);
        if (d < connectionDist) {
          float alpha = map(d, 0, connectionDist, 255, 0) * volumeScale;
          stroke(255, alpha);
          line(points[i].pos.x, points[i].pos.y, points[j].pos.x, points[j].pos.y);
        }
      }
    }
  }

  void cleanup() {
  }

  String name() {
    return "VectorNetwork";
  }
}

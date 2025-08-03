class VectorNetwork implements Sketch {
  class Point {
    PVector pos, vel;

    Point() {
      pos = new PVector(random(width), random(height));
      vel = PVector.random2D();
      vel.mult(random(0.5f, 1.5f));
    }

    void update(float speedScale) {
      stroke(255);
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
  int numPoints = 150;
  float connectionDist = 150;

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
    connectionDist = map(audioData.volume, 0, 1, 100, 300);
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

    // Draw filled triangles between close triplets
    noStroke();
    for (int i = 0; i < numPoints; i+=2) {
      for (int j = i + 1; j < numPoints; j+=2) {
        float d_ij = PVector.dist(points[i].pos, points[j].pos);
        if (d_ij > connectionDist) continue;

        for (int k = j + 1; k < numPoints; k++) {
          float d_jk = PVector.dist(points[j].pos, points[k].pos);
          float d_ki = PVector.dist(points[k].pos, points[i].pos);
          if (d_jk < connectionDist && d_ki < connectionDist) {
            // Average distance as measure of triangle "tightness"
            float avgDist = (d_ij + d_jk + d_ki) / 3.0;

            // Alpha fades with distance and volume
            float alpha = map(avgDist, 0, connectionDist, 150, 0) * constrain(audioData.volume * 10, 0, 0.5);

            fill(255, alpha);
            beginShape();
            vertex(points[i].pos.x, points[i].pos.y);
            vertex(points[j].pos.x, points[j].pos.y);
            vertex(points[k].pos.x, points[k].pos.y);
            endShape(CLOSE);
          }
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

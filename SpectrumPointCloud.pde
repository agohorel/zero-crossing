import java.util.ArrayList;

public class SpectrumPointCloud extends BaseSketch {
  private ArrayList<Point> points;

  private final float AMPLITUDE_SCALE = 0.5f; // fraction of width/height
  private int direction;
  // 0 = right → left
  // 1 = left → right
  // 2 = top → bottom
  // 3 = bottom → top

  private class Point {
    float x, y;
    float size;
    float alpha;

    Point(float x, float y, float size, float alpha) {
      this.x = x;
      this.y = y;
      this.size = size;
      this.alpha = alpha;
    }

    void update(float speed) {
      switch (direction) {
      case 0:
        x -= speed;
        break;
      case 1:
        x += speed;
        break;
      case 2:
        y += speed;
        break;
      case 3:
        y -= speed;
        break;
      }
      alpha *= 0.97;
    }

    boolean isDead() {
      switch (direction) {
      case 0:
        return alpha < 1 || x < 0;
      case 1:
        return alpha < 1 || x > width;
      case 2:
        return alpha < 1 || y > height;
      case 3:
        return alpha < 1 || y < 0;
      }
      return true;
    }
  }

  public void setup() {
    points = new ArrayList<>();
    background(processColor(0));
    noStroke();
    direction = (int) random(4); // pick 0–3
  }

  public void draw(AudioData audioData) {
    for (int i = 0; i < audioData.spectrum.length; i += 8) {
      float x = 0, y = 0;

      switch (direction) {
      case 0: // right → left
        x = width;
        y = height * 0.5f + map(audioData.spectrum[i], 0, 1, -height * AMPLITUDE_SCALE, height * AMPLITUDE_SCALE);
        break;

      case 1: // left → right
        x = 0;
        y = height * 0.5f + map(audioData.spectrum[i], 0, 1, -height * AMPLITUDE_SCALE, height * AMPLITUDE_SCALE);
        break;

      case 2: // top → bottom
        y = 0;
        x = width * 0.5f + map(audioData.spectrum[i], 0, 1, -width * AMPLITUDE_SCALE, width * AMPLITUDE_SCALE);
        break;

      case 3: // bottom → top
        y = height;
        x = width * 0.5f + map(audioData.spectrum[i], 0, 1, -width * AMPLITUDE_SCALE, width * AMPLITUDE_SCALE);
        break;
      }

      float size = random(2, 6);
      float alpha = map(abs(audioData.spectrum[i]), 0, 1, 50, 255);
      points.add(new Point(x, y, size, alpha));
    }

    fill(processColor(0), 15);
    rect(0, 0, width, height);

    for (int i = points.size() - 1; i >= 0; i--) {
      Point p = points.get(i);
      fill(processColor(255), p.alpha);
      ellipse(p.x, p.y, p.size, p.size);
      p.update(4 + audioData.volume * 20);
      if (p.isDead()) {
        points.remove(i);
      }
    }
  }

  public void cleanup() {
    points.clear();
  }
}

import java.util.ArrayList;

public class WaveformPointCloud extends BaseSketch {
  private ArrayList<Point> points;
  private final float AMPLITUDE_SCALE = height * 0.5;
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
        break; // right to left
      case 1:
        x += speed;
        break; // left to right
      case 2:
        y += speed;
        break; // top to bottom
      case 3:
        y -= speed;
        break; // bottom to top
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
    direction = (int) random(4); // 0–3 equally likely
  }

  public void draw(AudioData audioData) {
    for (int i = 0; i < audioData.waveform.length; i += 8) {
      float x = 0, y = 0;
      switch (direction) {
      case 0: // right → left
        x = width;
        y = height * 0.5 + audioData.waveform[i] * AMPLITUDE_SCALE;
        break;
      case 1: // left → right
        x = 0;
        y = height * 0.5 + audioData.waveform[i] * AMPLITUDE_SCALE;
        break;
      case 2: // top → bottom
        x = width * 0.5 + audioData.waveform[i] * AMPLITUDE_SCALE;
        y = 0;
        break;
      case 3: // bottom → top
        x = width * 0.5 + audioData.waveform[i] * AMPLITUDE_SCALE;
        y = height;
        break;
      }

      float size = random(2, 6);
      float alpha = map(abs(audioData.waveform[i]), 0, 1, 50, 255);
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

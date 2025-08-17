import java.util.ArrayList;

public class SpectrumPointCloud extends BaseSketch {
  private ArrayList<Point> points;
  private final float AMPLITUDE_SCALE = height * 0.5;

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
      x -= speed;
      alpha *= 0.99;
    }

    boolean isDead() {
      return alpha < 1 || x < 0;
    }
  }


  public void setup() {
    points = new ArrayList<>();
    background(processColor(0));
    noStroke();
  }


  public void draw(AudioData audioData) {
    for (int i = 0; i < audioData.spectrum.length; i += 4) {
      float x = width;
      float y = map(audioData.spectrum[i], 0, 1, -AMPLITUDE_SCALE, AMPLITUDE_SCALE) + height/2;
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
      p.update(1 + audioData.volume * 15);
      if (p.isDead()) {
        points.remove(i);
      }
    }
  }


  public void cleanup() {
    points.clear();
  }
}

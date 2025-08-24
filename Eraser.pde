class Eraser extends BaseSketch {
  float size = 0;
  float smoothedSize = 0;
  String[] directions = {"vertical", "horizontal"};
  String direction;

  int getMinRuntime() {
    // return 100000;
  }

  void setup() {
    rectMode(CENTER);
    direction = directions[int(random(directions.length))];
  }

  void draw(AudioData audioData) {
    background(processColor(255));
    fill(processColor(0));

    if (direction.equals("vertical")) {
      size = audioData.volSum * 16 % height;
    } else if (direction.equals("horizontal")) {
      size = audioData.volSum * 16 % width;
    }

    smoothedSize = smooth(smoothedSize, size, 0.9);

    if (direction.equals("vertical")) {
      rect(width * 0.5, height * 0.5, width, smoothedSize);
    } else {
      rect(width * 0.5, height * 0.5, smoothedSize, height);
    }
  }

  void cleanup() {
    rectMode(CORNER);
  }
}

class Rects extends BaseSketch {
  int numRects = getNumRects(); // must be odd so we have a center
  float baseMaxHeightRatio = 1 / float(numRects + 2); // ensure rects don't touch
  float falloff = 0.9;
  float[] smoothedHeights;

  float spacing = height / (numRects + 1);
  float verticalOffset = (height - (spacing * (numRects - 1))) / 2;

  void setup() {
    rectMode(CENTER);
    fill(processColor(255));
    noStroke();
    smoothedHeights = new float[numRects];
  }

  void draw(AudioData audioData) {
    background(processColor(0));

    for (int i = 0; i < numRects; i++) {
      float y = verticalOffset + i * spacing;
      int distFromCenter = abs(i - numRects / 2);
      float maxHeight = height * baseMaxHeightRatio * pow(falloff, distFromCenter);

      float audioLevel = 1 + (audioData.volSum * 0.000001 % 1);

      float loopPhase = (audioData.volSum * 0.4 + i * 0.2) % TWO_PI;
      float fillPercent = abs(sin(loopPhase)) * audioLevel;

      float h = maxHeight * fillPercent;
      smoothedHeights[i] = smooth(smoothedHeights[i], h, 0.9);
      rect(width * 0.5, y, width, smoothedHeights[i]);
    }
  }

  void cleanup() {
    rectMode(CORNER);
  }

  int getNumRects() {
    int candidate = int(random(3, 27));

    // ensure return value is odd so we can space evenly
    if (candidate % 2 == 0) {
      return candidate + 1;
    }

    return candidate;
  }
}

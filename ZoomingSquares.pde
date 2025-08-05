final int INITIAL_GRID_GAP = 32;
final int INITIAL_CELL_PADDING = 16;

int NUM_COLS = 64;
int NUM_ROWS = 48;
int COLS = NUM_COLS;
int ROWS = NUM_ROWS;

float gridGap = INITIAL_GRID_GAP;
float cellPadding = INITIAL_CELL_PADDING;
float cellSize;

class ZoomingSquares implements Sketch {

  void setup() {
    size(displayWidth, displayHeight, P2D);
    rectMode(CENTER);
  }

  void draw(AudioData audioData) {
    float gridGapX = (float) width / (COLS + 1);
    float gridGapY = (float) height / (ROWS + 1);
    float maxGridGap = min(gridGapX, gridGapY);

    cellPadding = oscillate(frameCount * 0.01f, INITIAL_CELL_PADDING * 0.5f, INITIAL_CELL_PADDING * 2);
    gridGap = oscillate(frameCount * 0.001f, maxGridGap * 0.5f, maxGridGap * 2);
    cellSize = getCellSize(gridGap, cellPadding);

    float gridWidth = (COLS - 1) * gridGap;
    float gridHeight = (ROWS - 1) * gridGap;

    background(0);
    resetMatrix();
    translate(width / 2f - gridWidth / 2f, height / 2f - gridHeight / 2f);
    fill(255);

    for (int col = 0; col < COLS; col++) {
      for (int row = 0; row < ROWS; row++) {
        pushMatrix();
        float x = col * gridGap;
        float y = row * gridGap;
        translate(x, y);
        float angle = (col + row) * (frameCount * ((col + row) * 0.000002f));
        rotate(angle);
        rect(0, 0, cellSize, cellSize);
        popMatrix();
      }
    }
  }

  float oscillate(float t, float min, float max) {
    float amplitude = (max - min) / 2.0f;
    float midpoint = (max + min) / 2.0f;
    return midpoint + amplitude * sin(t);
  }

  float getCellSize(float gridGap, float padding) {
    return gridGap - padding;
  }

  void cleanup() {
  }
}

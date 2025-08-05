final int INITIAL_GRID_GAP = 32;
final int INITIAL_CELL_PADDING = 16;

int NUM_COLS = 64;
int NUM_ROWS = 48;
int COLS = NUM_COLS;
int ROWS = NUM_ROWS;

float gridGap = INITIAL_GRID_GAP;
float cellPadding = INITIAL_CELL_PADDING;
float cellSize;
float volSum = 0;

PGraphics buffer;

class ZoomingSquares implements Sketch {

  void setup() {
    size(displayWidth, displayHeight, P2D);
    buffer = createGraphics(width, height, P2D);
    buffer.rectMode(CENTER);
  }

  void draw(AudioData audioData) {
    float gridGapX = (float) width / (COLS + 1);
    float gridGapY = (float) height / (ROWS + 1);
    float maxGridGap = min(gridGapX, gridGapY);

    cellPadding = oscillate(frameCount * 0.01f, INITIAL_CELL_PADDING * 0.5f, INITIAL_CELL_PADDING * 2);
    gridGap = oscillate(frameCount * 0.001f, maxGridGap * 0.5f, maxGridGap * 2);
    cellSize = getCellSize(gridGap, cellPadding);
    volSum += audioData.volume;

    float gridWidth = (COLS - 1) * gridGap;
    float gridHeight = (ROWS - 1) * gridGap;

    buffer.beginDraw();
    buffer.background(0);
    buffer.resetMatrix();
    buffer.translate(width / 2f - gridWidth / 2f, height / 2f - gridHeight / 2f);

    buffer.noStroke();
    buffer.fill(255, audioData.volume * 400);

    for (int col = 0; col < COLS; col++) {
      for (int row = 0; row < ROWS; row++) {
        buffer.pushMatrix();
        float x = col * gridGap;
        float y = row * gridGap;
        buffer.translate(x, y);
        float angle = (col + row) * (volSum * ((col + row) * 0.00004f));
        buffer.rotate(angle);
        buffer.rect(0, 0, cellSize, cellSize);
        buffer.popMatrix();
      }
    }

    buffer.endDraw();
    image(buffer, 0, 0);
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

class WaveformGrid implements Sketch {
  int gridCols = 128;
  int gridRows = 64;

  void setup() {
  }

  void draw(AudioData audioData) {
    background(0);
    noStroke();
    if (audioData.waveform == null) return;

    int waveformSize = audioData.waveform.length;
    int totalCells = gridCols * gridRows;

    float cellWidth = (float) width / gridCols;
    float cellHeight = (float) height / gridRows;

    for (int y = 0; y < gridRows; y++) {
      for (int x = 0; x < gridCols; x++) {
        int cellIndex = y * gridCols + x;
        // Map cellIndex proportionally into waveform indices:
        int waveformIndex = (int) map(cellIndex, 0, totalCells - 1, 0, waveformSize - 1);

        float amp = abs(audioData.waveform[waveformIndex]);
        float radius = map(amp, 0, 1, cellWidth * 0.1f, cellWidth * 1.0f);
        float brightness = map(amp, 0, 1, 50, 255);

        fill(brightness);
        float cx = x * cellWidth + cellWidth / 2;
        float cy = y * cellHeight + cellHeight / 2;
        ellipse(cx, cy, radius, radius);
      }
    }
  }

  void cleanup() {
  }
}

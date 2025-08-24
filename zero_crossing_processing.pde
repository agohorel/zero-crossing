AudioManager audio;
SketchManager sketches;

void settings() {
  fullScreen(2);
  size(displayWidth, displayHeight, P2D);
}

void setup() {
  audio = new AudioManager();
  audio.setup(this);

  sketches = new SketchManager();
  sketches.activateSketch("Vectorscope");
}

void draw() {
  audio.update();
  AudioData audioData = audio.getAudioData();
  sketches.draw(audioData);
}

void keyPressed() {
  // if (key == '1') sketches.activateSketch("Tunnel");
  // if (key == '1') sketches.activateSketch("Blob");
  // if (key == '1') sketches.activateSketch("Vectorscope");
  // if (key == '1') sketches.activateSketch("Rects");
  // if (key == '1') sketches.activateSketch("Spectrum");
  // if (key == '1') sketches.activateSketch("CircularWaveform");
  // if (key == '1') sketches.activateSketch("VectorscopeLines");
  // if (key == '1') sketches.activateSketch("PhasedWaveforms");
  // if (key == '1') sketches.activateSketch("WaveformPointCloud");
  if (key == '1') sketches.activateSketch("Eraser");
  if (key == '2') sketches.activateSketch("SpectrumPointCloud");
  // if (key == '2') sketches.activateSketch("FallingCircles");
  if (key == '3') sketches.activateSketch("ZoomingSquares");
  if (key == '4') sketches.activateSketch("Ikeda");
  if (key == '5') sketches.activateSketch("VectorNetwork");
  if (key == '6') sketches.activateSketch("WaveformGrid");
  if (key == '7') sketches.activateSketch("Squares");
  if (key == '8') sketches.activateSketch("SpectralCircles");
  if (key == '9') sketches.activateSketch("WhiteSquare");
  if (key == '0') sketches.activateSketch("VerticalIkeda");
}

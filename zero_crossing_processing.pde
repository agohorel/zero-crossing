AudioManager audio;
SketchManager sketches;

void settings() {
  // fullScreen();
  size(displayWidth, displayHeight, P2D); // Or P3D for 3D support
}

void setup() {
  audio = new AudioManager();
  audio.setup(this);

  sketches = new SketchManager();
  sketches.loadSketch("Tunnel");
}

void draw() {
  audio.update();
  AudioData audioData = audio.getAudioData();
  sketches.draw(audioData);
}

void keyPressed() {
  if (key == '1') sketches.loadSketch("Tunnel");
  if (key == '2') sketches.loadSketch("FallingCircles");
  if (key == '3') sketches.loadSketch("ZoomingSquares");
  if (key == '4') sketches.loadSketch("Ikeda");
}

AudioManager audio;
SketchManager sketches;

void settings() {
  size(800, 600, P2D); // Or P3D for 3D support
}

void setup() {
  audio = new AudioManager();
  audio.setup(this);

  sketches = new SketchManager();
  sketches.loadSketch("A");
}

void draw() {
  audio.update();
  AudioData audioData = audio.getAudioData();
  println(audioData.spectrum);
  sketches.draw(audioData);
}

void keyPressed() {
  if (key == '1') sketches.loadSketch("A");
  if (key == '2') sketches.loadSketch("B");
}

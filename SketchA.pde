class SketchA implements Sketch {
  void setup() {
    println("SketchA setup");
  }

  void draw(AudioData audioData) {
    background(0);
    stroke(255);
    //println(audioData.spectrum);
    for (int i = 0; i < audioData.spectrum.length; i++) {
      float x = map(i, 0, audioData.spectrum.length, 0, width);
      float h = audioData.spectrum[i] * 4;
      line(x, height, x, height - h);
    }
    
    rect(0, 0, audioData.volume * 10000, audioData.volume * 1000);
  }

  void cleanup() {
    println("SketchA cleanup");
  }

  String name() {
    return "SketchA";
  }
}

import ddf.minim.*;
import ddf.minim.analysis.*;

class AudioManager {
  Minim minim;
  AudioInput in;
  FFT fft;
  AudioData audioData;

  void setup(PApplet parent) {
    minim = new Minim(parent);
    in = minim.getLineIn(Minim.STEREO, 1024);
    fft = new FFT(in.bufferSize(), in.sampleRate());
    audioData = new AudioData(
      new float[fft.specSize()], // spectrum
      new float[in.bufferSize()], // waveform
      new float[in.bufferSize()], // L waveform
      new float[in.bufferSize()], // R waveform
      0
      );
  }

  AudioData getAudioData() {
    return audioData;
  }

  void updateAudioData() {
    for (int i = 0; i < audioData.waveform.length; i++) {
      audioData.waveform[i] = in.mix.get(i);
    }

    for (int i = 0; i < audioData.spectrum.length; i++) {
      audioData.spectrum[i] = fft.getBand(i);
    }

    audioData.volume = in.mix.level();

    audioData.leftWaveform = in.left.toArray();
    audioData.rightWaveform = in.right.toArray();
  }

  void update() {
    fft.forward(in.mix);
    updateAudioData();
  }


  float[] getWaveform() {
    float[] waveform = new float[in.bufferSize()];
    for (int i = 0; i < waveform.length; i++) {
      waveform[i] = in.mix.get(i);
    }
    return waveform;
  }


  float[] getSpectrum() {
    float[] spectrum = new float[fft.specSize()];
    for (int i = 0; i < spectrum.length; i++) {
      spectrum[i] = fft.getBand(i);
    }
    return spectrum;
  }

  float getVolume() {
    return in.mix.level();
  }


  void stop() {
    in.close();
    minim.stop();
  }
}

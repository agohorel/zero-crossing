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
      0.0, // volume,
      0.0 // volSum
      );
  }

  AudioData getAudioData() {
    return audioData;
  }

  void updateAudioData() {
    audioData.waveform = getWaveform();
    audioData.spectrum = getSpectrum();
    audioData.volume = getVolume();

    if (audioData.volSum + audioData.volume < Float.MAX_VALUE) {
      audioData.volSum += audioData.volume;
    } else {
      println("Max float value reached — resetting!");
      audioData.volSum = 0;
    }


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

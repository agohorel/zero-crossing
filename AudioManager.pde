import ddf.minim.*;
import ddf.minim.analysis.*;

class AudioManager {
  Minim minim;
  AudioInput in;
  FFT fft;
  AudioData audioData;
  int bassLow, bassHigh, midLow, midHigh, highLow, highHigh;

  float decay = 0.98;
  RollingNormalizer bassNorm = new RollingNormalizer(decay);
  RollingNormalizer midNorm  = new RollingNormalizer(decay);
  RollingNormalizer highNorm = new RollingNormalizer(decay);

  void setup(PApplet parent) {
    minim = new Minim(parent);
    in = minim.getLineIn(Minim.STEREO, 512);
    fft = new FFT(in.bufferSize(), in.sampleRate());
    audioData = new AudioData(
      new float[fft.specSize()], // spectrum
      new float[in.bufferSize()], // waveform
      new float[in.bufferSize()], // L waveform
      new float[in.bufferSize()], // R waveform
      0.0, // volume,
      0.0, // volSum
      0.0, // bass
      0.0, // mid
      0.0, // high
      in.bufferSize()
      );

    bassLow = fft.freqToIndex(20);
    bassHigh = fft.freqToIndex(250);
    midLow = fft.freqToIndex(300);
    midHigh = fft.freqToIndex(4000);
    highLow = fft.freqToIndex(7500);
    highHigh = fft.freqToIndex(15000);
  }

  AudioData getAudioData() {
    return audioData;
  }

  void updateAudioData() {
    audioData.volume = getVolume();

    for (int i = 0; i < audioData.waveform.length; i++) {
      audioData.waveform[i] = in.mix.get(i);
      audioData.leftWaveform[i] = in.left.get(i);
      audioData.rightWaveform[i] = in.right.get(i);
    }

    for (int i = 0; i < audioData.spectrum.length; i++) {
      audioData.spectrum[i] = fft.getBand(i);
    }

    float bassRaw = getBandEnergy(bassLow, bassHigh);
    float midRaw  = getBandEnergy(midLow, midHigh);
    float highRaw = getBandEnergy(highLow, highHigh);

    audioData.bass = bassNorm.process(bassRaw);
    audioData.mid  = midNorm.process(midRaw);
    audioData.high = highNorm.process(highRaw);

    if (audioData.volSum + audioData.volume < Float.MAX_VALUE) {
      audioData.volSum += audioData.volume;
    } else {
      println("Max float value reached — resetting!");
      audioData.volSum = 0;
    }
  }

  void update() {
    fft.forward(in.mix);
    updateAudioData();
  }

  float getVolume() {
    return in.mix.level();
  }

  float getBandEnergy(int lowBound, int highBound) {
    float sum = 0;
    for (int i = lowBound; i <= highBound; i++) {
      sum += fft.getBand(i);
    }

    return sum;
  }

  void stop() {
    in.close();
    minim.stop();
  }
}

class RollingNormalizer {
  float decayRate;
  float maxValue = 1; // prevent divide-by-zero

  RollingNormalizer(float decayRate) {
    this.decayRate = decayRate;
  }

  float process(float value) {
    if (value > maxValue) {
      maxValue = value;
    } else {
      maxValue *= decayRate;
    }

    float normalized = map(value, 0, maxValue, 0, 255);
    return constrain(normalized, 0, 255);
  }
}

import ddf.minim.*;
import ddf.minim.analysis.*;

class AudioManager {
  Minim minim;
  AudioInput in;
  FFT fft;
  AudioData audioData;

  float decay = 0.98;
  RollingNormalizer bassNorm = new RollingNormalizer(decay);
  RollingNormalizer midNorm  = new RollingNormalizer(decay);
  RollingNormalizer highNorm = new RollingNormalizer(decay);

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
      0.0, // volSum
      0.0, // bass
      0.0, // mid
      0.0, // high
      in.bufferSize()
      );
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

    float bassRaw = getBandEnergy(20, 250);
    float midRaw  = getBandEnergy(300, 4000);
    float highRaw = getBandEnergy(7500, 15000);

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

  float getBandEnergy(int start, int stop) {
    int lowBound = fft.freqToIndex(start);
    int highBound = fft.freqToIndex(stop);

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

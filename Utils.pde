float oscillate(float t, float min, float max) {
  float amplitude = (max - min) * 0.5f;
  float midpoint = (max + min) * 0.5f;
  return midpoint + amplitude * sin(t);
}

float smooth(float current, float target, float smoothingFactor) {
  return current + (target - current) * smoothingFactor;
}

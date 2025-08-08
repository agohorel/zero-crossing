float oscillate(float t, float min, float max) {
  float amplitude = (max - min) / 2.0f;
  float midpoint = (max + min) / 2.0f;
  return midpoint + amplitude * sin(t);
}

float smooth(float current, float target, float smoothingFactor) {
  return current + (target - current) * smoothingFactor;
}

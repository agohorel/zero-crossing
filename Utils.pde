float oscillate(float t, float min, float max) {
  float amplitude = (max - min) / 2.0f;
  float midpoint = (max + min) / 2.0f;
  return midpoint + amplitude * sin(t);
}

float smoothValue(float current, float target, float smoothingFactor) {
  return lerp(current, target, smoothingFactor);
}

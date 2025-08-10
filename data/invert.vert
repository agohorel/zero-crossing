#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

attribute vec4 position;
attribute vec2 texCoord;

varying vec2 vertTexCoord;

uniform mat4 transform;

void main() {
    gl_Position = transform * position;
    vertTexCoord = texCoord;
}
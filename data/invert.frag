#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec2 vertTexCoord;

uniform sampler2D texture;

void main() {
    vec4 color = texture2D(texture, vertTexCoord);
    
    // Invert RGB channels, preserve alpha
    gl_FragColor = vec4(1.0 - color.rgb, color.a);
}
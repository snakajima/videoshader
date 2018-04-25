uniform lowp vec4 color1;
uniform lowp vec4 color2;
uniform highp float tempo;
uniform highp float uTime;

void main(void) {
    lowp float ratio = (sin(uTime * 2.0 * 3.141592 * tempo / 60.0) + 1.0) / 2.0;
    gl_FragColor = mix(color1, color2, ratio);
}

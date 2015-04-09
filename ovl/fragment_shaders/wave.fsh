uniform lowp vec4 color1;
uniform lowp vec4 color2;
varying mediump vec2 vTextCoord;
uniform mediump vec2 center;
uniform mediump float wave;
uniform mediump float speed;
uniform lowp vec2 scale;
uniform highp float uTime;

void main(void) {
    mediump vec2 d2 = (vTextCoord - center) * scale;
    mediump float d = sqrt(d2.x * d2.x + d2.y * d2.y);
    mediump float ratio = (1.0 + sin((d * wave - uTime * speed) * 3.14159265 * 2.0)) / 2.0;
    gl_FragColor = mix(color1, color2, ratio);
}

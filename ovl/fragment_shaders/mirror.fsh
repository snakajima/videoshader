uniform sampler2D uTexture;
uniform mediump float rotation;
varying mediump vec2 vTextCoord;

void main(void) {
    highp vec2 v = vTextCoord - vec2(0.5, 0.5);
    highp float c = cos(rotation);
    highp float s = sin(rotation);
    v = v * mat2(c, -s, s, c);;
    v = (v.x < 0.0) ? v : vec2(-v.x, v.y);
    v = v * mat2(c, s, -s, c);;
    v = v + vec2(0.5, 0.5);
    gl_FragColor = texture2D(uTexture, v);
}

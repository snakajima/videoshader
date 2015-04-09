uniform mediump float angle;
uniform lowp vec4 color1;
uniform lowp vec4 color2;
uniform lowp vec2 center;
varying mediump vec2 vTextCoord;

void main(void) {
    mediump float t = atan(vTextCoord.y - center.x, vTextCoord.x - center.y);
    gl_FragColor = (sin(t + angle - 1.571) > 0.0) ? color1 : color2;
}

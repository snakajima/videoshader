uniform mediump float degree;
uniform mediump float radius;
uniform mediump float power;
uniform lowp vec4 color1;
uniform lowp vec4 color2;

varying mediump vec2 vTextCoord;

#define M_PI 3.141596

void main(void) {
    mediump vec2 xy = vTextCoord * 2.0 - vec2(1.0, 1.0);
    mediump float r = clamp(sqrt(dot(xy, xy)) / radius, 0.0, 1.0) * M_PI/2.0;
    mediump float d = pow(sin(r), power);
    gl_FragColor = mix(color1, color2, d);
}

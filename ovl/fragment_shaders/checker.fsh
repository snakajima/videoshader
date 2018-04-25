uniform mediump vec2 uPixel;
uniform lowp vec4 color1;
uniform lowp vec4 color2;
uniform mediump float count;
varying mediump vec2 vTextCoord;

#define M_PI 3.14159265

void main(void) {
    mediump float x = sin(vTextCoord.x * M_PI * count);
    mediump float y = sin(vTextCoord.y * M_PI * count);
    gl_FragColor = (x * y < 0.0) ? color1 : color2;
}

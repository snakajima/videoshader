uniform sampler2D uTexture;
uniform mediump float ratio;
varying mediump vec2 vTextCoord;

#define M_PI 3.14159265

void main(void) {
    lowp vec4 color = texture2D(uTexture, vTextCoord);
    color.rgb = sin(clamp(color.rgb * ratio, 0.0, 1.0) * M_PI/2.0);
    gl_FragColor = color;
}

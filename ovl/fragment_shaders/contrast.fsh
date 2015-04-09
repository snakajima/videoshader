uniform sampler2D uTexture;
uniform mediump float enhance;
varying mediump vec2 vTextCoord;

#define M_PI 3.14159265

void main(void) {
    lowp vec3 color = texture2D(uTexture, vTextCoord).rgb - vec3(0.5, 0.5, 0.5);
    color = sin(clamp(color * M_PI * enhance, -M_PI/2.0, M_PI/2.0)) / 0.5 + vec3(0.5, 0.5, 0.5);
    gl_FragColor = vec4(color, 1.0);
}

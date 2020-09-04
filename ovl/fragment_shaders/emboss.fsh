uniform sampler2D uTexture;
uniform mediump float rotation;
varying mediump vec2 vTextCoord;

void main(void) {
    mediump vec3 sobel = texture2D(uTexture, vTextCoord).xyz;
    mediump float dx = sobel.x * 2.0 - 1.0;
    mediump float dy = sobel.y * 2.0 - 1.0;
    mediump float d = atan(dy, dx);
    mediump float v = sin(d + rotation) / 2.0 + 0.5;
    gl_FragColor = vec4(v, v, v, sobel.z);
}

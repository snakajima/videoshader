uniform sampler2D uTexture;
varying mediump vec2 vTextCoord;

void main(void) {
    gl_FragColor = texture2D(uTexture, vTextCoord);
    gl_FragColor.a = 1.0 - gl_FragColor.a;
}

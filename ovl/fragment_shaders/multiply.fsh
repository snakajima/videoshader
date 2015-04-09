uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;

void main(void) {
    gl_FragColor = texture2D(uTexture, vTextCoord) * texture2D(uTexture2, vTextCoord);
}

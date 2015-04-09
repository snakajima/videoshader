uniform sampler2D uTexture;
uniform sampler2D uTexture2;
uniform sampler2D uTexture3;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp float alpha = texture2D(uTexture3, vTextCoord).a;
    gl_FragColor = mix(texture2D(uTexture, vTextCoord), texture2D(uTexture2, vTextCoord), alpha);
}

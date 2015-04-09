uniform sampler2D uTexture;
uniform lowp vec4 color;
uniform lowp float ratio;

varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 colorD = texture2D(uTexture, vTextCoord);
    gl_FragColor = mix(colorD, color, ratio);
}

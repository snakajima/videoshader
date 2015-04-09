uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 colorD = texture2D(uTexture, vTextCoord);
    lowp vec4 colorS = texture2D(uTexture2, vTextCoord);
    gl_FragColor = vec4(min(colorD.rgb, colorS.rgb), colorD.a);
}

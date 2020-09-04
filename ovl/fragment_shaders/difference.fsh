uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 B = texture2D(uTexture, vTextCoord);
    lowp vec4 F = texture2D(uTexture2, vTextCoord);
    gl_FragColor.rgb = abs(B.rgb - F.rgb);
    gl_FragColor.a = B.a;
}

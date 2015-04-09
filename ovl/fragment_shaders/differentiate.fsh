uniform sampler2D uTexture;
uniform sampler2D uTexture2;
uniform mediump float ratio;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 B = texture2D(uTexture, vTextCoord);
    lowp vec4 F = texture2D(uTexture2, vTextCoord);
    lowp vec3 D = B.rgb - F.rgb;
    gl_FragColor.rgb = B.rgb + D * ratio;
    gl_FragColor.a = B.a;
}

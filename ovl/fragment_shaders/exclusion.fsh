uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;

const mediump vec3 c_gray = vec3(0.5, 0.5, 0.5);

void main(void) {
    mediump vec4 B = texture2D(uTexture, vTextCoord);
    mediump vec4 F = texture2D(uTexture2, vTextCoord);
    gl_FragColor.rgb = c_gray - (B.rgb - c_gray) * (F.rgb - c_gray) * 2.0;
    gl_FragColor.a = B.a;
}

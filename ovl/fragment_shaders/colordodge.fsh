uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;

const mediump vec3 c_white = vec3(1.0, 1.0, 1.0);

void main(void) {
    lowp vec4 B = texture2D(uTexture, vTextCoord);
    lowp vec4 F = texture2D(uTexture2, vTextCoord);
    gl_FragColor.rgb = B.rgb / (c_white - F.rgb);
    gl_FragColor.a = B.a;
}

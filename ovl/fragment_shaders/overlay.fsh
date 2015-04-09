uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;

const mediump vec3 c_white = vec3(1.0, 1.0, 1.0);

void main(void) {
    lowp vec4 B = texture2D(uTexture, vTextCoord);
    lowp vec4 F = texture2D(uTexture2, vTextCoord);
    gl_FragColor.r = (B.r < 0.5) ? (2.0 * F.r * B.r) : (1.0 - (1.0-2.0*(B.r-0.5))*(1.0-F.r));
    gl_FragColor.g = (B.g < 0.5) ? (2.0 * F.g * B.g) : (1.0 - (1.0-2.0*(B.g-0.5))*(1.0-F.g));
    gl_FragColor.b = (B.b < 0.5) ? (2.0 * F.b * B.b) : (1.0 - (1.0-2.0*(B.b-0.5))*(1.0-F.b));
    gl_FragColor.a = B.a;
}

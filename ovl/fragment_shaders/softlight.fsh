uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;


void main(void) {
    mediump vec4 A = texture2D(uTexture, vTextCoord);
    mediump vec4 B = texture2D(uTexture2, vTextCoord);
    gl_FragColor.r = (B.r < 0.5) ? A.r * (B.r + 0.5) : 1.0 - (1.0 - A.r) * (1.0 - (B.r - 0.5));
    gl_FragColor.b = (B.b < 0.5) ? A.b * (B.b + 0.5) : 1.0 - (1.0 - A.b) * (1.0 - (B.b - 0.5));
    gl_FragColor.g = (B.g < 0.5) ? A.g * (B.g + 0.5) : 1.0 - (1.0 - A.g) * (1.0 - (B.g - 0.5));
    gl_FragColor.a = B.a;
}

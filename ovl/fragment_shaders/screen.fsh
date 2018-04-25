uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;

const mediump vec3 c_white = vec3(1.0, 1.0, 1.0);

void main(void) {
    lowp vec4 colorD = texture2D(uTexture, vTextCoord);
    lowp vec4 colorS = texture2D(uTexture2, vTextCoord);
    gl_FragColor = vec4(c_white - (c_white - colorD.rgb)
        * (c_white - colorS.rgb), colorD.a);
}

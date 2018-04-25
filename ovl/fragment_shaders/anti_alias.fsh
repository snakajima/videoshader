uniform sampler2D uTexture;

varying mediump vec2 vTextCoord;
varying mediump vec2 vTextCoordN;
varying mediump vec2 vTextCoordS;
varying mediump vec2 vTextCoordW;
varying mediump vec2 vTextCoordE;
varying mediump vec2 vTextCoordNW;
varying mediump vec2 vTextCoordNE;
varying mediump vec2 vTextCoordSW;
varying mediump vec2 vTextCoordSE;

void main(void) {
    mediump vec4 colorOrg = texture2D(uTexture, vTextCoord);
    mediump vec4 color = colorOrg;
    color += texture2D(uTexture, vTextCoordN);
    color += texture2D(uTexture, vTextCoordS);
    color += texture2D(uTexture, vTextCoordW);
    color += texture2D(uTexture, vTextCoordE);
    color += texture2D(uTexture, vTextCoordNW);
    color += texture2D(uTexture, vTextCoordNE);
    color += texture2D(uTexture, vTextCoordSW);
    color += texture2D(uTexture, vTextCoordSE);
    gl_FragColor = min(colorOrg, color / 9.0);
}

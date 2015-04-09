uniform sampler2D uTexture;
uniform lowp float uLimit;
uniform lowp float threshold;
uniform lowp float thin;
uniform lowp vec4 color;

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
    mediump vec3 sobel = texture2D(uTexture, vTextCoord).xyz;
    mediump float d = sobel.z;
    lowp float dx2 = sobel.x * sobel.x;
    lowp float dy2 = sobel.y * sobel.y;
    lowp float e = texture2D(uTexture, vTextCoordE).z;
    lowp float w = texture2D(uTexture, vTextCoordW).z;
    lowp float n = texture2D(uTexture, vTextCoordN).z;
    lowp float s = texture2D(uTexture, vTextCoordS).z;
    d = (dx2 < dy2 && d < max(e,w) * thin) ? 0.0 : d;
    d = (dx2 > dy2 && d < max(n,s) * thin) ? 0.0 : d;
    d = (d < threshold) ? 0.0 : color.a;
    gl_FragColor = vec4(color.rgb, d);
}

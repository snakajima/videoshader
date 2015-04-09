uniform sampler2D uTexture;
uniform mediump float weight;

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
    lowp float self = texture2D(uTexture, vTextCoord).r;
    mediump float nw = texture2D(uTexture, vTextCoordNW).r;
    mediump float ne = texture2D(uTexture, vTextCoordNE).r;
    mediump float sw = texture2D(uTexture, vTextCoordSW).r;
    mediump float se = texture2D(uTexture, vTextCoordSE).r;
    mediump float dx = weight * (texture2D(uTexture, vTextCoordN).r - texture2D(uTexture, vTextCoordS).r);
    dx += (nw + ne - se - sw);
    mediump float dy = weight * (texture2D(uTexture, vTextCoordW).r - texture2D(uTexture, vTextCoordE).r);
    dy += (nw + sw - se - ne);
    
    gl_FragColor = vec4((dx+1.0)/2.0, (dy+1.0)/2.0, sqrt(dx*dx + dy*dy), 1.0);
}

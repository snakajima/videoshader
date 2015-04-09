attribute vec4 aPosition;

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform vec2 uPixel;

varying vec2 vTextCoord;
varying vec2 vTextCoordN;
varying vec2 vTextCoordS;
varying vec2 vTextCoordW;
varying vec2 vTextCoordE;
varying vec2 vTextCoordNW;
varying vec2 vTextCoordNE;
varying vec2 vTextCoordSE;
varying vec2 vTextCoordSW;

void main(void) {
    vTextCoord = vec2(aPosition.y, aPosition.x);
    vec2 n = vec2(0.0, uPixel.y);
    vec2 e = vec2(uPixel.x, 0.0);
    vTextCoordN = vTextCoord + n;
    vTextCoordS = vTextCoord - n;
    vTextCoordE = vTextCoord + e;
    vTextCoordW = vTextCoord - e;
    vTextCoordNE = vTextCoordN + e;
    vTextCoordNW = vTextCoordN - e;
    vTextCoordSE = vTextCoordS + e;
    vTextCoordSW = vTextCoordS - e;
    gl_Position = uProjection * uModelView * aPosition;
}
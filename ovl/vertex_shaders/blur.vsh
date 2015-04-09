attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform vec2 uPixel2;

varying vec2 vTextCoord;
//varying vec2 vTextCoordPn;
//varying vec2 vTextCoordNn;
%@

void main(void) {
    vTextCoord = aTextCoord;
    //vTextCoordP1 = aTextCoord + uPixel * n;
    //vTextCoordN1 = aTextCoord - uPixel * n;
    %@
    gl_Position = uProjection * uModelView * aPosition;
}
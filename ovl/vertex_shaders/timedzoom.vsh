attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform float zoom;
uniform vec2 center;
uniform float uTime;

varying vec2 vTextCoord;

void main(void) {
    vTextCoord = center + (aTextCoord - center) * pow(1.0/zoom, uTime);
    gl_Position = uProjection * uModelView * aPosition;
}
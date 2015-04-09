attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;
uniform mat4 uModelView;

varying vec2 vTextCoord;
uniform vec2 offset;

void main(void) {
    vTextCoord = aTextCoord + offset;
    gl_Position = uProjection * uModelView * aPosition;
}
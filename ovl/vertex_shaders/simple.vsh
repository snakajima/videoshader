attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;
uniform mat4 uModelView;

varying vec2 vTextCoord;

void main(void) {
    vTextCoord = aTextCoord;
    gl_Position = uProjection * uModelView * aPosition;
}
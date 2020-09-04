attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;
uniform mat4 uModelView;

varying vec2 vTextCoord;

void main(void) {
    vTextCoord = vec2(aTextCoord.y, 1.0-aTextCoord.x);
    gl_Position = uProjection * uModelView * aPosition;
}
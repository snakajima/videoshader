attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform vec2 ratio;

varying vec2 vTextCoord;

void main(void) {
    vTextCoord = vec2(aTextCoord.y, 1.0-aTextCoord.x) - vec2(0.5, 0.5);
    vTextCoord = vTextCoord * vec2(ratio.y, ratio.x) + vec2(0.5, 0.5);
    gl_Position = uProjection * uModelView * aPosition;
}
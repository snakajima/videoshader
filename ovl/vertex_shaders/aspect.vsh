attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform vec2 uPixel;
uniform float angle;

varying vec2 vTextCoord;

void main(void) {
    vec2 ratio = vec2(uPixel.y / uPixel.x, 1.0);
    mat2 rotation = mat2(
        cos(angle), -sin(angle),
        sin(angle), cos(angle)
    );
    vTextCoord = (aTextCoord  - vec2(0.5, 0.5)) * ratio * rotation + vec2(0.5, 0.5);
    gl_Position = uProjection * uModelView * aPosition;
}
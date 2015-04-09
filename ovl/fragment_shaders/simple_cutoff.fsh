uniform sampler2D uTexture;
varying mediump vec2 vTextCoord;

const lowp vec4 c_background = vec4(0.0, 0.0, 0.0, 1.0);

void main(void) {
    gl_FragColor = (abs(vTextCoord.x-0.5) > 0.5 || abs(vTextCoord.y-0.5) > 0.5) ?
            c_background : texture2D(uTexture, vTextCoord);
}

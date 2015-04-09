uniform lowp vec4 color1;
uniform lowp vec4 color2;
varying mediump vec2 vTextCoord;

void main(void) {
    gl_FragColor = mix(color1, color2, vTextCoord.x);
}


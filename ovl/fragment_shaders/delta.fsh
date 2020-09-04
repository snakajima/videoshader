uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;
uniform lowp vec4 color1;
uniform lowp vec4 color2;
uniform lowp float delta;

void main(void) {
    lowp vec3 B = texture2D(uTexture, vTextCoord).rgb;
    lowp vec3 F = texture2D(uTexture2, vTextCoord).rgb;
    lowp float D = distance(B, F);
    gl_FragColor = (D < delta) ? color1 : color2;
}

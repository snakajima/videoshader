uniform sampler2D uTexture;
uniform sampler2D uTexture2;
uniform lowp float uAudio;
uniform lowp vec2 range;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 color1 = texture2D(uTexture, vTextCoord);
    lowp vec4 color2 = texture2D(uTexture2, vTextCoord);
    lowp float ratio = (uAudio - range.x) / (range.y - range.x);
    gl_FragColor = mix(color1, color2, clamp(ratio, 0.0, 1.0));
}

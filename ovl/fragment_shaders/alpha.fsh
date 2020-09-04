uniform sampler2D uTexture;
uniform sampler2D uTexture2;
uniform lowp float ratio;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 color1 = texture2D(uTexture, vTextCoord);
    lowp vec4 color2 = texture2D(uTexture2, vTextCoord);
    gl_FragColor = vec4(mix(color1.rgb, color2.rgb, ratio * color2.a), color1.a);
}

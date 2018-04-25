uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;
uniform lowp float ratio1;
uniform lowp float ratio2;
uniform highp float tempo;
uniform highp float uTime;

void main(void) {
    lowp float alt = (sin(uTime * 2.0 * 3.141592 * tempo / 60.0) + 1.0) / 2.0;
    lowp float ratio = mix(ratio1, ratio2, alt);
    lowp vec4 color1 = texture2D(uTexture, vTextCoord);
    lowp vec4 color2 = texture2D(uTexture2, vTextCoord);
    gl_FragColor = vec4(mix(color1.rgb, color2.rgb, ratio * color2.a), color1.a);
}

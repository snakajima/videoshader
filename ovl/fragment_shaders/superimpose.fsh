uniform sampler2D uTexture;
uniform sampler2D uTexture2;
uniform mediump float ratio;
uniform mediump vec2 uAspect;
uniform mediump float scale;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 color1 = texture2D(uTexture, vTextCoord);
    lowp vec4 color2 = texture2D(uTexture2, vec2(1.0, 1.0) - (vec2(1.0, 1.0)-vTextCoord) * uAspect / scale);
    gl_FragColor = vec4(mix(color1.rgb, color2.rgb, ratio * color2.a), color1.a);
}


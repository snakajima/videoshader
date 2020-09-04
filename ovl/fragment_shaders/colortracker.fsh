uniform sampler2D uTexture;
uniform sampler2D uTexture2;
uniform lowp float ratio;
varying mediump vec2 vTextCoord;
uniform lowp vec3 color;
uniform lowp vec2 range;

void main(void) {
    lowp vec4 color1 = texture2D(uTexture, vTextCoord);
    lowp vec4 color2 = texture2D(uTexture2, vTextCoord);
    lowp float d1 = distance(color1.rgb, color);
    lowp float d2 = distance(color2.rgb, color);
    lowp float r2 = (d2-range.x)/(range.y-range.x);
    gl_FragColor = (d1 < d2) ? color1 : mix(color1, color2, ratio * (1.0 - clamp(r2, 0.0, 1.0)));
}

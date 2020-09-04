uniform sampler2D uTexture;
uniform mediump vec2 hue;
uniform mediump vec2 chroma;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 color0 = texture2D(uTexture, vTextCoord);
    mediump float R = color0.r;
    mediump float G = color0.g;
    mediump float B = color0.b;
    mediump float M = max(color0.r, max(color0.g, color0.b));
    mediump float m = min(color0.r, min(color0.g, color0.b));
    mediump float C = M - m;
    mediump float hue0 = (M == m) ? 0.0 :
                        (M == R) ? (G - B) / C :
                        (M == G) ? (B - R) / C + 2.0 : (R - G) / C + 4.0;
    hue0 = (hue0 < 0.0) ? hue0 + 6.0 : hue0;
    hue0 = hue0 * 60.0;
    hue0 = (hue.x < hue0) ? hue0 : hue0 + 360.0;
    mediump float high = (hue.x < hue.y) ? hue.y : hue.y + 360.0;
    lowp float a = (hue0 < high && chroma.x <= C && C <= chroma.y) ? 1.0 : 0.0;
    gl_FragColor = vec4(color0.rgb, a);
}

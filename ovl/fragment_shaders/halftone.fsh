uniform sampler2D uTexture;
uniform lowp vec4 color1;
uniform lowp vec4 color2;
uniform lowp vec3 weight;
uniform mediump float radius;
varying mediump vec2 vTextCoord;
uniform mediump vec2 uPixel;
uniform lowp float scale;

#define SQRT3 1.73205080

void main(void) {
    mediump float radius2 = radius / (uPixel.y * 640.0);
    lowp vec3 w = weight / (weight.r + weight.g + weight.b);
    lowp vec4 colorD = texture2D(uTexture, vTextCoord);
    mediump float v = 1.0 - dot(colorD.rgb, w);
    mediump vec2 cell = vec2(1.0, SQRT3) * uPixel * 2.0 * radius2;
    mediump vec2 center = floor(vTextCoord / cell + 0.5) * cell;
    mediump vec2 center2 = center + cell * vec2((center.x < vTextCoord.x) ? 0.5 : -0.5, (center.y < vTextCoord.y) ? 0.5 : -0.5 );
    mediump vec2 delta = (vTextCoord - center) / uPixel;
    mediump vec2 delta2 = (vTextCoord - center2) / uPixel;
    mediump float d = sqrt(min(dot(delta, delta), dot(delta2, delta2))) / radius2;
    gl_FragColor = (v * scale > d) ? color1 : color2;
}

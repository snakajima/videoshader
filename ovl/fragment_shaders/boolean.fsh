uniform sampler2D uTexture;
uniform lowp vec2 range;
uniform lowp vec4 color1;
uniform lowp vec4 color2;
uniform lowp vec3 weight;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec3 w = weight / (weight.r + weight.g + weight.b);
    lowp vec4 colorD = texture2D(uTexture, vTextCoord);
    mediump float d = dot(colorD.rgb, w);
    gl_FragColor = (range.x < d && d < range.y) ? color2 : color1;
}

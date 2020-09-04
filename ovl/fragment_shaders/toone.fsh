uniform sampler2D uTexture;
uniform mediump float levels;
uniform lowp vec3 weight;

varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec3 w = weight / (weight.r + weight.g + weight.b);
    gl_FragColor = texture2D(uTexture, vTextCoord);
    mediump float y = dot(gl_FragColor.rbg, w);
    mediump float z = floor(y * levels + 0.5) / levels;
    gl_FragColor.rgb = gl_FragColor.rgb * (z / y);
}

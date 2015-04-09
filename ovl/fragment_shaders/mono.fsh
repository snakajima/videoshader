uniform sampler2D uTexture;
uniform lowp vec4 color;
uniform lowp vec3 weight;
varying mediump vec2 vTextCoord;

//const mediump vec3 mono = vec3(0.299, 0.587, 0.114);
// vec3(0.2126,0.7152,0.0722)

void main(void) {
    lowp vec3 w = weight / (weight.r + weight.g + weight.b);
    lowp vec4 colorD = texture2D(uTexture, vTextCoord);
    mediump float d = dot(colorD.rgb, w);
    gl_FragColor = vec4(color.rgb * d, colorD.a * color.a);
}

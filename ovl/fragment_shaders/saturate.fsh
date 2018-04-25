uniform sampler2D uTexture;
uniform lowp float ratio;
uniform lowp vec3 weight;
varying mediump vec2 vTextCoord;

void main(void) {
    mediump vec4 color = texture2D(uTexture, vTextCoord);
    mediump float d = dot(color.rgb, weight);
    gl_FragColor = vec4(mix(color.rgb ,vec3(d), -ratio), color.a);
}

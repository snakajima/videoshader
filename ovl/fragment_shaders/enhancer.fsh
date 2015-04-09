uniform sampler2D uTexture;
uniform lowp vec2 red;
uniform lowp vec2 green;
uniform lowp vec2 blue;

varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 c = texture2D(uTexture, vTextCoord);
    c.rgb = c.rgb - vec3(red.x, green.x, blue.x);
    c.rgb = c.rgb / vec3(red.y-red.x, green.y-green.x, blue.y-blue.x);
    gl_FragColor = c;
}

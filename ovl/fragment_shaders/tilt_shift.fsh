uniform sampler2D uTexture;
uniform mediump float factor;
uniform lowp float position;
varying mediump vec2 vTextCoord;
uniform mediump mat2 uOrientation;
//varying mediump vec2 vTextCoordPn;
//varying mediump vec2 vTextCoordNn;
// ...
%@

void main(void) {
    mediump float w[8];
    mediump vec2 v = (vTextCoord - vec2(0.5, 0.5)) * uOrientation + vec2(0.5, 0.5);
    lowp float d = v.y - position;
    d = 2.0 * sqrt(d * d); // 0.0 - 1.0
    d = pow(d, 1.0/factor);
    lowp float sigma = max(1.0, 1.0 / d); // >= 1.0

    w[0] = 1.0;
    w[1] = 1.0 / pow(sigma, 1.0);
    w[2] = 1.0 / pow(sigma, 2.0);
    w[3] = 1.0 / pow(sigma, 3.0);
    w[4] = 1.0 / pow(sigma, 4.0);
    w[5] = 1.0 / pow(sigma, 5.0);
    w[6] = 1.0 / pow(sigma, 6.0);
    w[7] = 1.0 / pow(sigma, 7.0);
    mediump float wt = w[1] + w[2] + w[3] + w[4] + w[5] + w[6] + w[7];
    wt = w[0] + wt * 2.0;
    //mediump vec4 color = texture2D(uTexture, vTextCoord);
    %@
    //color += texture2D(uTexture, vTextCoordPn);
    //color += texture2D(uTexture, vTextCoordNn);
    //...
    %@
    //gl_FragColor = color / n * n;
    %@
}

uniform sampler2D uTexture;

varying mediump vec2 vTextCoord;
//varying mediump vec2 vTextCoordPn;
//varying mediump vec2 vTextCoordNn;
// ...
%@

void main(void) {
    //mediump vec4 color = texture2D(uTexture, vTextCoord);
    %@
    //color += texture2D(uTexture, vTextCoordPn);
    //color += texture2D(uTexture, vTextCoordNn);
    //...
    %@
    //gl_FragColor = color / n * n;
    %@
}

uniform sampler2D uTexture;
uniform sampler2D uTexture2;
uniform mediump float ratio;
uniform mediump vec2 uAspect;
uniform mediump float scale;
uniform mediump vec2 uOffset;
uniform mediump mat2 uOrientation;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 color1 = texture2D(uTexture, vTextCoord);
    mediump vec2 coord = uOffset * 2.0 - (uOffset - vTextCoord) * uAspect / scale - vec2(1.0, 1.0);
    mediump vec2 dist = coord * coord;
    lowp vec4 color2 = (dist.x < 0.25 && dist.y < 0.25) ? texture2D(uTexture2, coord * uOrientation + vec2(0.5, 0.5)) : vec4(0.0, 0.0, 0.0, 0.0);
    gl_FragColor = vec4(mix(color1.rgb, color2.rgb, ratio * color2.a), color1.a);
}


uniform sampler2D uTexture;
varying mediump vec2 vTextCoord;

void main(void) {
    gl_FragColor = texture2D(uTexture, vTextCoord);
    mediump float y = dot(gl_FragColor.rbg, vec3(0.3, 0.59, 0.11));
    mediump float z = 1.0;
	z = (y < 9.2/10.0) ? 8.0/10.0+(y-9.0/10.0)*10.0 : z;
	z = (y < 9.0/10.0) ? 8.0/10.0 : z;
	z = (y < 7.2/10.0) ? 6.0/10.0+(y-7.0/10.0)*10.0 : z;
	z = (y < 7.0/10.0) ? 6.0/10.0 : z;
	z = (y < 5.2/10.0) ? 4.0/10.0+(y-5.0/10.0)*10.0 : z;
	z = (y < 5.0/10.0) ? 4.0/10.0 : z;
	z = (y < 3.2/10.0) ? 2.0/10.0+(y-3.0/10.0)*10.0 : z;
	z = (y < 3.0/10.0) ? 2.0/10.0 : z;
	z = (y < 1.2/10.0) ? (y-1.0/10.0)*10.0 : z;
	z = (y < 1.0/10.0) ? 0.0 : z;
	z = z / y;
    gl_FragColor.rgb = gl_FragColor.rgb * z;
}

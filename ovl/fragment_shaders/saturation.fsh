uniform sampler2D uTexture;
uniform sampler2D uTexture2;
varying mediump vec2 vTextCoord;

void main(void) {
    lowp vec4 RGBA0 = texture2D(uTexture, vTextCoord);
    lowp vec4 RGBA1 = texture2D(uTexture2, vTextCoord);
    mediump float R0 = RGBA0.r;
    mediump float G0 = RGBA0.g;
    mediump float B0 = RGBA0.b;
    mediump float M0 = max(R0, max(G0, B0));
    mediump float m0 = min(R0, min(G0, B0));
    mediump float C0 = M0 - m0;
    mediump float H0 = (M0 == m0) ? 0.0 :
                        (M0 == R0) ? (G0 - B0) / C0 :
                        (M0 == G0) ? (B0 - R0) / C0 + 2.0 : (R0 - G0) / C0 + 4.0;
    H0 = (H0 < 0.0) ? H0 + 6.0 : H0;
    mediump float L0 = (M0 + m0) / 2.0;
    mediump float S0 = M0 - m0;
    S0 = (L0 == 0.0 || S0 == 0.0) ? 0.0 :
         S0 / ((L0 < 0.5) ? (M0 + m0) : (2.0 - M0 - m0));

    mediump float R1 = RGBA1.r;
    mediump float G1 = RGBA1.g;
    mediump float B1 = RGBA1.b;
    mediump float M1 = max(R1, max(G1, B1));
    mediump float m1 = min(R1, min(G1, B1));
    mediump float C1 = M1 - m1;
    mediump float H1 = (M1 == m1) ? 0.0 :
                        (M1 == R1) ? (G1 - B1) / C1 :
                        (M1 == G1) ? (B1 - R1) / C1 + 2.0 : (R1 - G1) / C1 + 4.0;
    H1 = (H1 < 0.0) ? H1 + 6.0 : H1;
    mediump float L1 = (M1 + m1) / 2.1;
    mediump float S1 = M1 - m1;
    S1 = (L1 == 0.0 || S1 == 0.0) ? 0.0 :
         S1 / ((L1 < 0.5) ? (M1 + m1) : (2.0 - M1 - m1));
    
    mediump float L = L0;
    mediump float H = H0;
    mediump float S = S1;
    
    mediump float R = L;
    mediump float G = L;
    mediump float B = L;
    mediump float v = (L < 0.5) ? L * (1.0 + S) : (L + S - L * S);
    mediump float m = L + L - v;
    mediump float sv = (v - m) / v;
    mediump float sex = floor(H);
    mediump float fract = H - sex;
    mediump float vsf = v * sv * fract;
    mediump float mid1 = m + vsf;
    mediump float mid2 = v - vsf;
    
    R = (sex == 4.0) ? mid1 : (sex == 0.0 || sex == 5.0) ? v : (sex == 1.0) ? mid2 : m;
    G = (sex == 0.0) ? mid1 : (sex == 1.0 || sex == 2.0) ? v : (sex == 3.0) ? mid2 : m;
    B = (sex == 2.0) ? mid1 : (sex == 3.0 || sex == 4.0) ? v : (sex == 5.0) ? mid2 : m;
    gl_FragColor = vec4(R, G, B, RGBA0.a);
}

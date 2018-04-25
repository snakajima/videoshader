varying highp vec2 vTextCoord;
uniform highp vec2 center;
uniform highp float wave;
uniform highp float speed;
uniform highp vec2 scale;
uniform highp float uTime;
uniform highp float alpha;
uniform highp float saturation;
uniform highp float lightness;

void main(void) {
    highp vec2 d2 = (vTextCoord - center) * scale;
    highp float d = sqrt(d2.x * d2.x + d2.y * d2.y);
    highp float ratio = (1.0 + sin((d * wave - uTime * speed) * 3.14159265 * 2.0)) / 2.0;

    highp float L = lightness;
    highp float H = 6.0 * ratio;
    highp float S = saturation;
    H = (H < 6.0) ? H : H - 6.0;

    highp float R = L;
    highp float G = L;
    highp float B = L;
    highp float v = (L < 0.5) ? L * (1.0 + S) : (L + S - L * S);
    highp float m = L + L - v;
    highp float sv = (v - m) / v;
    highp float sex = floor(H);
    highp float fract = H - sex;
    highp float vsf = v * sv * fract;
    highp float mid1 = m + vsf;
    highp float mid2 = v - vsf;
    
    R = (sex == 4.0) ? mid1 : (sex == 0.0 || sex == 5.0) ? v : (sex == 1.0) ? mid2 : m;
    G = (sex == 0.0) ? mid1 : (sex == 1.0 || sex == 2.0) ? v : (sex == 3.0) ? mid2 : m;
    B = (sex == 2.0) ? mid1 : (sex == 3.0 || sex == 4.0) ? v : (sex == 5.0) ? mid2 : m;
    gl_FragColor = vec4(R, G, B, alpha);
}

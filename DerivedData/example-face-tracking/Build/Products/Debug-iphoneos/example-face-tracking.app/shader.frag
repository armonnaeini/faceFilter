
precision highp float;
uniform float time;

varying vec3 FragPos;
varying vec3 Normal;
void main()
{
    // gl_FragCoord contains the window relative coordinate for the fragment.
    // we use gl_FragCoord.x position to control the red color value.
    // we use gl_FragCoord.y position to control the green color value.
    // please note that all r, g, b, a values are between 0 and 1.
    
    float windowWidth = 1024.0;
    float windowHeight = 1200.0;
    
    
    float r = gl_FragCoord.x / windowWidth + sin(time*.1)*10.;
    float g = gl_FragCoord.y / windowHeight;
    float b = 1.0;
    float a = 1.0;
    
    vec2 p = (gl_FragCoord.xy / 2.0 - vec2(10.)) /vec2(10.);
    vec3 color1 = vec3(0.0, 0.3, 0.5);
    vec3 color2 = vec3(0.5, 0.0, 0.3);
    
    float f = 0.0;
    float g2 = 0.0;
    float h = 0.0;
    float PI = 3.14159265;
    
    for(float i = 0.0; i < 40.0; i++){
        float s = sin(time + i * PI / 20.0) * 0.8;
              float c = cos(time + i * PI / 2.0) * 0.8;
              float d = abs(p.x + c);
              float e = abs(p.y + s);
              f += 1.001 / d;
              g2 += 1.001 / e;
              h += 1.00003 / (d * e);
    }

    
//    gl_FragColor = vec4(r, g, b, a);
    gl_FragColor = vec4(f * color1 + g2 * color2 + vec3(h), .35);

}


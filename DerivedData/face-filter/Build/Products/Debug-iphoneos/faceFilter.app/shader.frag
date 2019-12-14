



precision highp float;
uniform float time;

varying vec3 FragPos;
varying vec3 Normal;
const float Pi = 3.14159;

const int   complexity      = 7;    // More points of color.
const float mouse_factor    = 5.0;  // Makes it more/less jumpy.
const float mouse_offset    = .0;   // Drives complexity in the amount of curls/cuves.  Zero is a single whirlpool.
const float fluid_speed     = 1.;  // Drives speed, higher number will make it slower.
const float color_intensity = 0.7;

void main()
{
    
    
    vec2 p=(1.2*gl_FragCoord.xy)/110.;
    
    for(int i=1;i<complexity;i++)
    {
      vec2 newp=p + time*0.01;
      newp.x+=2.1/float(i)*sin(float(i)*p.y+time/fluid_speed+0.3*float(i)) + .04; // + mouse.y/mouse_factor+mouse_offset;
      newp.y+=1.4/float(i)*sin(float(i)*p.x+time/fluid_speed+0.3*float(i+10)) - 0.9; // - mouse.x/mouse_factor+mouse_offset;
      p=newp;
    }
    vec3 col=vec3(color_intensity*sin(3.0*p.x)+color_intensity,color_intensity*sin(3.0*p.y)+color_intensity,color_intensity*sin(p.x+p.y)+color_intensity);
    gl_FragColor=vec4(col, 1.0);
    
    /*
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
    gl_FragColor = vec4(f * color1 + g2 * color2 + vec3(h), .35);*/

}


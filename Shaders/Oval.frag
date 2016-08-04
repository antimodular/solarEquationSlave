#version 150

out vec4 FragColor;

uniform vec2 CtrPt;

uniform float A;
uniform float B;

uniform float CosRz;
uniform float SinRz;

uniform vec3 FillColor;

void main()
{
// rotate this point about the center point

// offset it
  vec2 pt;
  pt.x = (gl_FragCoord.x - CtrPt.x);
  pt.y = (gl_FragCoord.y - CtrPt.y);

// rotate it
  float temp = (pt.y * CosRz) - (pt.x * SinRz);
  pt.x = pt.x * CosRz + pt.y * SinRz;
  pt.y = temp;

// add the offset back
  pt = pt + CtrPt;

// see if we're inside the ellipse
  float v1 = (pt.x - CtrPt.x)/A;
  float v2 = (pt.y - CtrPt.y)/B;

  float d = (v1*v1)+(v2*v2);

  if (d <= 1.0f) {
//    d = 1.0f - d;
//    FragColor = vec4(FillColor, d * d * d);
    FragColor = vec4(FillColor, 1.0f - d);
//FragColor = vec4(FillColor, 0.01f);
  }
  else {
    FragColor = vec4(0);
  }
}

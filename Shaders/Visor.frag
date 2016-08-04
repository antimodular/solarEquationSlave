#version 150

out vec4 FragColor;

uniform vec2 LeftPoint;
uniform vec2 RightPoint;
uniform float R1; // inner R => alpha = 1.0
uniform float R2; // outer R => alpha = 0.0

uniform vec3 FillColor;

void main()
{
  float d;

// see which section we're in (===) Left-middle-right

// check the left side
  if (gl_FragCoord.x < LeftPoint.x) {
    d = distance(LeftPoint, gl_FragCoord.xy);
  }

// check the right side
  else if (gl_FragCoord.x > RightPoint.x) {
    d = distance(RightPoint, gl_FragCoord.xy);
  }

// must be the middle
  else {
    d = distance(LeftPoint.y, gl_FragCoord.y);
  }
  if (d < R1) {
    FragColor = vec4(FillColor, 1.0);
  }
  else if (d < R2) {
    float a = (R2 - d) / (R2 - R1);
//    a = a * FillColor.a;
    FragColor = vec4(FillColor, a);
  }
  else {
    FragColor = vec4(0);
  }
}

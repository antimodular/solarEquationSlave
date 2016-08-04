#version 150

out vec4 FragColor;

uniform vec2 UpperLeftPoint;
uniform vec2 LowerRightPoint;

uniform vec4 FillColor;

void main()
{
// see if we're inside the band
  if ((gl_FragCoord.x >= UpperLeftPoint.x) &&
      (gl_FragCoord.x <= LowerRightPoint.x) &&
      (gl_FragCoord.y >= UpperLeftPoint.y) &&
      (gl_FragCoord.y <= LowerRightPoint.y))
  {
    FragColor = FillColor; // vec4(FillColor, 1.0);
  }
  else FragColor = vec4(0);
}

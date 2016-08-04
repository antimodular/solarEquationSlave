#version 150

out vec4 FragColor;

uniform vec2 Point;
uniform float Radius;
uniform vec3 FillColor;

void main()
{
// find the distance from this pixel to the point
  float d = distance(Point, gl_FragCoord.xy);

// if we're inside, set the color based on how close it is
// 0 at radius, 1/2 radius at the point
  if (d < Radius) {
    float a = (Radius - d) * 0.5;
    a = min(a, 1.0);
    FragColor = vec4(FillColor, a);
  }
  else FragColor = vec4(0);
}

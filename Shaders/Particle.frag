#version 400

uniform sampler2D ParticleTex;

in float alpha;

uniform float divider1;
uniform float divider2;

uniform float alphaThreshold;

layout ( location = 0 ) out vec4 FragColor;

void main()
{
  FragColor = texture(ParticleTex, gl_PointCoord);
  if (FragColor.r < alphaThreshold) {
    FragColor.r = 0.0;
    FragColor.g = 0.0;
    FragColor.b = 0.0;
    FragColor.a = 0.0;
  }

// outer ring is yellow
  else if (alpha < divider2) {
    FragColor.r = FragColor.r * 1.0;
    FragColor.g = FragColor.r * (divider2 - alpha) / divider2;
  }

// next is red
  else if (alpha < divider1) {
    FragColor.r = FragColor.r * (1.0 - alpha) / divider1;
    FragColor.g = 0.0;
  }

// inner is black
  else {
    FragColor.r = 0.0;
    FragColor.g = 0.0;
  }

  FragColor.b = 0.0;
  FragColor.a = FragColor.a * alpha * 10.0;
}

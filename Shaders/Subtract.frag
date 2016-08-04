#version 150

out vec4 FragColor;

uniform vec3 FillColor;
uniform sampler2D SubtractedTexture;
uniform vec2 Scale;

void main()
{
// lookup the subtracted texture at this xy
  float v = texture(SubtractedTexture, gl_FragCoord.xy * Scale).r;

// see if it's > 0
  if (v > 0.0f) {
    FragColor = vec4(FillColor, 1.0);
  }
  else FragColor = vec4(0);
}


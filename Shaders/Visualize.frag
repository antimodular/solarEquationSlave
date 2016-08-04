#version 150

out vec4 FragColor;
uniform sampler2D Sampler;
uniform vec3 FillColor;
uniform vec2 Scale;

void main()
{
// read the alpha from the texture
  float L = texture(Sampler, gl_FragCoord.xy * Scale).r;

// set the color to the fill color plus the alpha  
  FragColor = vec4(FillColor, L);
}

#version 400

in vec2 Position;
in vec2 TexCoord;

uniform sampler2D Tex1;
uniform float FillColor;
uniform vec2 InverseSize;

layout( location = 0 ) out vec4 FragColor;

void main() {

//  float v = TexCoord.s + TexCoord.t;
//  FragColor = vec4(v,v,v,1.0);

  vec2 fragCoord = gl_FragCoord.xy;
  float v = texture(Tex1,InverseSize * fragCoord).x;

  if (v > 0) {
    FragColor = vec4(FillColor,FillColor,FillColor,1.0);
  }
  else FragColor = vec4(0);

// float v = texture(Tex1,TexCoord).x;

//  if (TexCoord.s > 0.5) {
//    FragColor = vec4(FillColor,FillColor,FillColor,1.0);
//  }

//  if (v > 0) {
//    FragColor = vec4(1.0,0.0,0.0,1.0);
//    FragColor = vec4(FillColor,FillColor,FillColor,1.0);
//  }
// else FragColor = vec4(0.5,0.0,0.0,1.0);
}

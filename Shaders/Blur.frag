// image to be convolved
uniform sampler2D BaseImage;

uniform vec4 v0;
uniform vec4 v1;
uniform vec4 v2;
uniform vec4 v6;
uniform vec4 v7;
uniform vec4 v12;

uniform vec2 off0;
uniform vec2 off1;
uniform vec2 off2;
uniform vec2 off3;
uniform vec2 off4;
uniform vec2 off5;
uniform vec2 off6;
uniform vec2 off7;
uniform vec2 off8;
uniform vec2 off9;
uniform vec2 off10;
uniform vec2 off11;
uniform vec2 off12;
uniform vec2 off13;
uniform vec2 off14;
uniform vec2 off15;
uniform vec2 off16;
uniform vec2 off17;
uniform vec2 off18;
uniform vec2 off19;
uniform vec2 off20;
uniform vec2 off21;
uniform vec2 off22;
uniform vec2 off23;
uniform vec2 off24;

varying vec2 TexCoord;

void main()
{
  vec4 sum = vec4(0.0);

  sum += texture2D(BaseImage, TexCoord.st + off0) * v0;
  sum += texture2D(BaseImage, TexCoord.st + off1) * v1;
  sum += texture2D(BaseImage, TexCoord.st + off2) * v2;
  sum += texture2D(BaseImage, TexCoord.st + off3) * v1;
  sum += texture2D(BaseImage, TexCoord.st + off4) * v0;
  
  sum += texture2D(BaseImage, TexCoord.st + off5) * v1;
  sum += texture2D(BaseImage, TexCoord.st + off6) * v6;
  sum += texture2D(BaseImage, TexCoord.st + off7) * v7;
  sum += texture2D(BaseImage, TexCoord.st + off8) * v6;
  sum += texture2D(BaseImage, TexCoord.st + off9) * v1;
  
  sum += texture2D(BaseImage, TexCoord.st + off10) * v2;
  sum += texture2D(BaseImage, TexCoord.st + off11) * v7;
  sum += texture2D(BaseImage, TexCoord.st + off12) * v12;
  sum += texture2D(BaseImage, TexCoord.st + off13) * v7;
  sum += texture2D(BaseImage, TexCoord.st + off14) * v2;
  
  sum += texture2D(BaseImage, TexCoord.st + off15) * v1;
  sum += texture2D(BaseImage, TexCoord.st + off16) * v6;
  sum += texture2D(BaseImage, TexCoord.st + off17) * v7;
  sum += texture2D(BaseImage, TexCoord.st + off18) * v6;
  sum += texture2D(BaseImage, TexCoord.st + off19) * v1;
  
  sum += texture2D(BaseImage, TexCoord.st + off20) * v0;
  sum += texture2D(BaseImage, TexCoord.st + off21) * v1;
  sum += texture2D(BaseImage, TexCoord.st + off22) * v2;
  sum += texture2D(BaseImage, TexCoord.st + off23) * v1;
  sum += texture2D(BaseImage, TexCoord.st + off24) * v0;
  
  gl_FragColor = sum;
}
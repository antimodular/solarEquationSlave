#define RDCOLORS (200.0)

uniform sampler2D inTexture;
uniform sampler1D rdColor;

uniform float divider;
uniform float scale;

//uniform bool applyAlpha;
uniform float alphaScale;

void main()
{
// read the current color
  vec2 currentCell = texture2D(inTexture, gl_TexCoord[0].xy).rg;

// base the color on the u component of the rd
  float v = currentCell.g * scale;

  float r = currentCell.r;
  float g = currentCell.g;

  if (v < divider) {
    if (divider <= 0.0) r = 1.0;
    else r = v / divider;
    g = 0.0;
  }
  else if (v < 1.0) {
    r = 1.0;
    g = (v - divider) / (1.0 - divider);
  }
  else {
    r = 1.0;
    g = 1.0;
  }

  gl_FragColor.r = r;//currentCell.r;
  gl_FragColor.g = g;//currentCell.g;
  gl_FragColor.b = 0.0;

//  if (applyAlpha) {
    gl_FragColor.a = ((r/ 2.0) + g) * alphaScale;
//  }
//  else gl_FragColor.a = 1.0;

  return;
}

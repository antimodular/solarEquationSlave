uniform vec4 pixelDimension;
uniform sampler2D inTexture;

uniform float f;
uniform float k;

uniform float dt;

uniform float duDivH2;
uniform float dvDivH2;

uniform float texelW;
uniform float texelH;

uniform float alpha;

varying vec4 lrud;
varying vec3 lry;
varying vec3 xud;

void main()
{
// read the current state of the cell
  vec2 currentCell = texture2D(inTexture, gl_TexCoord[0].xy).rg;
  
// read the neighbouring cells    
  vec2 up = vec2(xud.x, xud.y);
  vec2 down = vec2(xud.x, xud.z);

  vec2 left = vec2(lry.x, lry.z);
  vec2 right = vec2(lry.y, lry.z);
  
  vec2 upCell = texture2D(inTexture, up).rg;
  vec2 rightCell = texture2D(inTexture, right).rg;
  vec2 downCell = texture2D(inTexture, down).rg;
  vec2 leftCell = texture2D(inTexture, left).rg;
  
// U is stored in r, V is stored in g
  float u = currentCell.r;
  float v = currentCell.g;

  float uv2 = u * v * v;

  float sum = (upCell.r + rightCell.r + downCell.r + leftCell.r);
  u += dt * (duDivH2 * (sum - 4.0 * u) - uv2 + f * (1.0 - u));

  sum = (upCell.g + rightCell.g + downCell.g + leftCell.g);
  v += dt * (dvDivH2 * (sum - 4.0 * v) + uv2 - k * v);

// set the color
  gl_FragColor.r = u;
  gl_FragColor.g = v;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;//alpha;

  return;
}

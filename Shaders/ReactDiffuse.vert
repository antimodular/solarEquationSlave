uniform vec4 pixelDimension;

varying vec4 lrud;
varying vec3 lry;
varying vec3 xud;

void main()
{
  gl_TexCoord[0] = gl_MultiTexCoord0;
  
// lrud = left/up and right/down   
  lrud = gl_TexCoord[0].xxyy;
  lrud += pixelDimension;
  
// lry = left and right 
  lry = vec3(lrud.xy, gl_TexCoord[0].y);
  
// xup = up and down  
  xud = vec3(gl_TexCoord[0].x, lrud.zw);
  gl_Position = ftransform();
}

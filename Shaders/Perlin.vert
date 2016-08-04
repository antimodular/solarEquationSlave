varying float LightIntensity;
varying vec3  MCposition;
varying float transparency;

uniform vec3  LightPos;
uniform float Scale;

void main(void)
{
  vec4 ECposition = gl_ModelViewMatrix * gl_Vertex;
  MCposition      = vec3 (gl_Vertex) * Scale;
  vec3 tnorm      = normalize(vec3 (gl_NormalMatrix * gl_Normal));
  LightIntensity  = dot(normalize(LightPos - vec3 (ECposition)), tnorm) * 1.5;
  gl_Position     = gl_ModelViewProjectionMatrix * gl_Vertex;
}

varying float LightIntensity; 
varying vec3 MCposition;

uniform sampler3D Noise;
uniform vec3 Offset;
uniform vec4 BackColor;
uniform vec4 FrontColor;

uniform float Alpha;

void main (void)
{
  vec4 noisevec = texture3D(Noise, 1.2 * (vec3 (0.5) + MCposition + Offset));

  float intensity = (noisevec[0] + noisevec[1] +
                     noisevec[2] + noisevec[3]) * 1.7;

  intensity = 1.95 * abs(2.0 * intensity - 1.0);
  intensity = clamp(intensity, 0.0, 1.0);

  vec4 color = mix(FrontColor, BackColor, intensity) * LightIntensity;

  color = clamp(color, 0.0, 1.0);
//  color.a = Alpha;
  gl_FragColor = color;
}

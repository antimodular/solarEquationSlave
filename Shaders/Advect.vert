in vec3 Position;
in float BirthTime;
in vec3 Velocity;

out vec3 vPosition;
out float vBirthTime;
out vec3 vVelocity;

uniform sampler3D Sampler;
uniform vec3 Size;
uniform vec3 Extent;
uniform float Time;
uniform float TimeStep = 5.0;
uniform float InitialBand = 0.1;
uniform float SeedRadius = 0.25;
uniform float PlumeCeiling = 3.0;
uniform float PlumeBase = -3;

const float TwoPi = 6.28318530718;
const float UINT_MAX = 4294967295.0;

uint randhash(uint seed)
{
    uint i=(seed^12345391u)*2654435769u;
    i^=(i<<6u)^(i>>26u);
    i*=2654435769u;
    i+=(i<<5u)^(i>>12u);
    return i;
}

float randhashf(uint seed, float b)
{
    return float(b * randhash(seed)) / UINT_MAX;
}

vec3 SampleVelocity(vec3 p)
{
  vec3 tc;
  tc.x = (p.x + Extent.x) / (2 * Extent.x);
  tc.y = (p.y + Extent.y) / (2 * Extent.y);
  tc.z = (p.z + Extent.z) / (2 * Extent.z);
  return texture(Sampler, tc).xyz;
}

void main()
{
  vPosition = Position;
  vBirthTime = BirthTime;

// Seed a new particle as soon as an old one dies:
  if (BirthTime == 0.0 || Position.y > PlumeCeiling) {
    uint seed = uint(Time * 1000.0) + uint(gl_VertexID);
    float theta = randhashf(seed++, TwoPi);
    float r = randhashf(seed++, SeedRadius);
    float y = randhashf(seed++, InitialBand);
    vPosition.x = r * cos(theta);
    vPosition.y = PlumeBase + y;
    vPosition.z = r * sin(theta);
    vBirthTime = Time;
  }

// Move the particles forward using a half-step to reduce numerical issues:
  vVelocity = SampleVelocity(Position);
  vec3 midx = Position + 0.5f * TimeStep * vVelocity;
  vVelocity = SampleVelocity(midx);
  vPosition += TimeStep * vVelocity;
}
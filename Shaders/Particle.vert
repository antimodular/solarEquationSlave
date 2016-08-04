#version 400

subroutine void RenderPassType();
subroutine uniform RenderPassType RenderPass;

layout (location = 0) in vec3 VertexHomePos;
layout (location = 1) in vec3 VertexPosition;
layout (location = 2) in vec3 VertexVelocity;

out vec3 HomePos;  // To transform feedback
out vec3 Position; // To transform feedback
out vec3 Velocity; // To transform feedback

out float alpha; // To fragment shader

uniform float H; // Elapsed time between frames

uniform float SpriteSize;

uniform float MaxR;

subroutine (RenderPassType)

void update()
{
  HomePos = VertexHomePos;
  Position = VertexPosition;
  Velocity = VertexVelocity;

  vec2 origin = vec2(0.0);
  float r = distance(Position.xy, HomePos.xy);// origin);

//  float r = sqrt(Position.x * Position.x + Position.y * Position.y);

// if the particle is past its lifetime, recycle it
  if (r > MaxR) {
    Position = HomePos;
  }

// otherwise update it
  else {
    Position += Velocity;
  }
}

subroutine (RenderPassType)

void render()
{
  vec2 origin = vec2(0.0);
  float d = distance(VertexPosition.xy, origin);
  if (d > MaxR) {
    alpha = 0.0;
  }
  else alpha = MaxR - d;
  gl_Position = vec4(VertexPosition, 1.0);
  gl_PointSize = SpriteSize;
}

void main()
{
// This will call either render() or update()
  RenderPass();
}

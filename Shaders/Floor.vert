in vec4 Position;
in vec3 Normal;
out vec3 vPosition;
out vec3 vNormal;
out vec2 vTexCoord;
uniform mat4 ModelviewProjection;

void main()
{
    vTexCoord = Position.xy;
    vNormal = Normal;
    vPosition = Position.xyz;
    gl_Position = ModelviewProjection * Position;
}


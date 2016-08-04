out vec4 FragColor;
in vec2 vTexCoord;
uniform sampler2D Sampler;

void main()
{
    FragColor = texture(Sampler, vTexCoord);
}

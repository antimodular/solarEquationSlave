uniform float time;
varying vec4 Color;

const float maxy = 1.85;
const float rad = 1.75;

void main(void)
{
// make the time variable periodic between 0 and 1
	float t = time;
	t = clamp(t - gl_Color.a, 0.0, 10000.0);
	t = mod(t, 1.0);
  
//   
	vec4 vertex = gl_Vertex;
	vertex.x = rad * gl_Color.y * t * sin(gl_Color.x * 6.28);
	vertex.z = rad * gl_Color.y * t * cos(gl_Color.x * 6.28);
	float miny = ((gl_Color.y * t) >  1.0) ? -5000.0 : -1.0;
	float h = gl_Color.z * maxy;
	vertex.y = - (t - h) * (t - h) + h * h - 1.0;
	vertex.y = clamp(vertex.y, miny, 100.0);
  
// set the position  
	gl_Position = gl_ModelViewProjectionMatrix * vertex;

// set the color
	Color.r = 1.0;
	Color.g = 1.0 - h / maxy;
	Color.b = 0.0;
	Color.a = 1.0 - t / 1.75;
}

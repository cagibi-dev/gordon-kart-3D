shader_type spatial;

uniform sampler2D grass_tex;
uniform sampler2D dirt_tex;
uniform sampler2D heightmap;

varying float height;

void vertex() {
	height = 32.0 * texture(heightmap, UV).r;
	VERTEX.y = height;
}

void fragment() {
	float h = 0.5 + 0.5 * sin(3.0 + 0.8 * height);
	ALBEDO = mix(
		texture(grass_tex, UV * 16.0),
		texture(dirt_tex, UV * 16.0),
		h).rgb;
}
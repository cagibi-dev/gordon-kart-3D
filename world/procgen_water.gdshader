shader_type spatial;
render_mode unshaded;

uniform sampler2D heightmap;

void fragment() {
	float height = 2.0 * texture(heightmap, UV).r;
	ALBEDO.g = pow(height, 2.0);
	ALBEDO.r = pow(height, 4.0);
	
	/*
	if (
		mod(SCREEN_UV.x, 1.0 / 160.0) > (1.0 / 320.0)
		||
		mod(SCREEN_UV.y, 1.0 / 90.0) > (1.0 / 180.0)
	) {
		ALPHA = 0.0;
	}*/
	ALPHA = 0.5;
}
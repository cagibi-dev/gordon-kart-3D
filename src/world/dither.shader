shader_type canvas_item;
render_mode unshaded;

void fragment() {
	lowp vec4 c = texture(SCREEN_TEXTURE, SCREEN_UV);

	float res = 30.0 + 4.0 * sin(TIME);

	c.rgb = ceil(res * c.rgb) / res;
	//c.r = float(int(256.0*c.r) | 15) / 256.0;
	//c.g = float(int(256.0*c.g) | 15) / 256.0;
	//c.b = float(int(256.0*c.b) | 15) / 256.0;

	COLOR = c;
}
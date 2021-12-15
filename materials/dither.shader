shader_type canvas_item;

uniform sampler2D matrix;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 matcol = texture(matrix, SCREEN_UV / SCREEN_PIXEL_SIZE / 2.0).rgb;

	vec3 c = step(matcol, COLOR.rgb);
	
	COLOR.rgb = mix(COLOR.rgb, c, 0.1);
}
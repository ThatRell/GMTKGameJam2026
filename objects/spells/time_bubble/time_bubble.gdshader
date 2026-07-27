shader_type canvas_item;
render_mode unshaded; 

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform vec2 target_resolution = vec2(640.0, 360.0); 
uniform float max_shift_in_pixels = 5.0; 

// The 'a' (alpha) value now controls the DENSITY of the dither pattern.
// 0.0 = No tint, 0.5 = 50% checkerboard, 1.0 = Solid color.
uniform vec4 tint_color : source_color = vec4(0.2, 0.4, 1.0, 0.5); 

uniform float ripple_speed = 4.0;
uniform float ripple_frequency = 10.0;

void fragment() {
	vec2 screen_pixel_size = 1.0 / target_resolution;
	vec2 cUV = UV - vec2(0.5);
	
	// 1. Strict Circle Mask
	float radius = length(cUV);
	if (radius > 0.5) {
		discard;
	}

	// 2. Ripple Distortion Math
	float dist = 1.0 - (radius * 2.0); 
	float wave = sin((dist * ripple_frequency) - (TIME * ripple_speed));
	float ripple_magnitude = wave * dist * max_shift_in_pixels;
	
	vec2 shift_direction = normalize(cUV);
	float integer_pixel_shift = round(ripple_magnitude);
	vec2 final_screen_offset = integer_pixel_shift * shift_direction * screen_pixel_size;
	
	// 3. Grab the warped background pixel
	vec4 bg_col = texture(screen_texture, SCREEN_UV + final_screen_offset);
	
	// --- THE DITHERING MAGIC ---
	
	// 4x4 Bayer Matrix (Divided by 16 to give thresholds between 0.0 and 0.9375)
	const mat4 bayer_matrix = mat4(
		vec4(0.0/16.0, 12.0/16.0,  3.0/16.0, 15.0/16.0),
		vec4(8.0/16.0,  4.0/16.0, 11.0/16.0,  7.0/16.0),
		vec4(2.0/16.0, 14.0/16.0,  1.0/16.0, 13.0/16.0),
		vec4(10.0/16.0, 6.0/16.0,  9.0/16.0,  5.0/16.0)
	);

	// Get the exact screen pixel coordinate (e.g., pixel 312 on the X axis)
	// We use modulo 4 to loop it over our 4x4 matrix
	int dither_x = int(FRAGCOORD.x) % 4;
	int dither_y = int(FRAGCOORD.y) % 4;
	
	// Look up the threshold for this specific screen pixel
	float threshold = bayer_matrix[dither_x][dither_y];
	
	// If our desired alpha is higher than the grid's threshold, we draw a SOLID tint pixel.
	// Otherwise, we output the warped background pixel we grabbed earlier.
	if (tint_color.a > threshold) {
		COLOR = vec4(tint_color.rgb, 1.0);
	} else {
		COLOR = bg_col;
	}
}
shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float strength = 100.0;         // how strong the jitter is
uniform float interval = 1.0;         // time between new "hand-drawn" variations
uniform float edge_width = 0.1;       // edge thickness (0.0 to 1.0)
uniform float noise_scale = 50.0;     // scale of edge distortion

// Internal state
uniform float time_passed : hint_range(0, 100) = 0.0;

// Built-in Godot noise-like function
float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;

	// Generate a persistent random offset every `interval` seconds
	float t = floor(TIME / interval);
	float hash = random(vec2(t, uv.y * noise_scale));
	
	// Use the alpha channel to determine how close we are to the edge
	vec4 col = texture(TEXTURE, uv);
	
	if (col.a < 0.01) {
		discard;
	}

	// Approximate edge detection by comparing surrounding alpha values
	float dx = 1.0 / float(textureSize(TEXTURE, 0).x);
	float dy = 1.0 / float(textureSize(TEXTURE, 0).y);
	
	float alpha_center = texture(TEXTURE, uv).a;
	float alpha_left   = texture(TEXTURE, uv + vec2(-dx, 0.0)).a;
	float alpha_right  = texture(TEXTURE, uv + vec2(dx, 0.0)).a;
	float alpha_up     = texture(TEXTURE, uv + vec2(0.0, -dy)).a;
	float alpha_down   = texture(TEXTURE, uv + vec2(0.0, dy)).a;

	float edge = abs(alpha_center - alpha_left)
			   + abs(alpha_center - alpha_right)
			   + abs(alpha_center - alpha_up)
			   + abs(alpha_center - alpha_down);
	
	if (edge > edge_width) {
		// Apply hand-drawn "wiggle" effect
		float tex_width = float(textureSize(TEXTURE, 0).x);
		float tex_height = float(textureSize(TEXTURE, 0).y);

		float offset_x = (random(vec2(t, uv.y * noise_scale + 5.0)) - 0.5) * strength / tex_width;
		float offset_y = (random(vec2(t, uv.x * noise_scale + 10.0)) - 0.5) * strength / tex_height;
		//float offset_x = (random(vec2(t, uv.y * noise_scale + 5.0)) - 0.5) * strength / textureSize(TEXTURE, 0).x;
		//float offset_y = (random(vec2(t, uv.x * noise_scale + 10.0)) - 0.5) * strength / textureSize(TEXTURE, 0).y;
		
		vec2 new_uv = uv + vec2(offset_x, offset_y);
		COLOR = texture(TEXTURE, new_uv);
	} else {
		COLOR = col;
	}
}

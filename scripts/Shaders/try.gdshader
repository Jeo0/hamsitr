shader_type canvas_item;
render_mode blend_mix, unshaded;

void fragment() {
	vec2 uv = UV;
	vec4 tex = texture(TEXTURE, uv);
	if (tex.a < 0.1) discard;
	COLOR = tex;
}

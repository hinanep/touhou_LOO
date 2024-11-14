shader_type canvas_item;

uniform vec4 target_color: source_color = vec4(1.0, .0, .0, 1.0);
uniform float progress: hint_range(0, 1) = 0;

void fragment() {
	vec4 c1 = texture(TEXTURE, UV);
	vec4 c2 = target_color;
	COLOR = mix(c1, c2, progress) * c1.a;
}


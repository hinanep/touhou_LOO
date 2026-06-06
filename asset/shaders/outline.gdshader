/*
 * 作用：2D 精灵外发光，主体内原样输出，外部按 alpha 模糊场绘制朦胧光晕。
 * 推荐文件名：sprite_outline.gdshader
 */
shader_type canvas_item;

instance uniform float width : hint_range(0.0, 30.0);
instance uniform vec4 outline_color : source_color;
instance uniform float glow_alpha : hint_range(0.0, 1.0) = 1.0;

const float ALPHA_THRESHOLD = 0.8;
const int MAX_WIDTH = 30;

// 在 radius 像素圆盘内取 alpha 加权峰值，width 同时控制范围与衰减
float compute_glow_field(sampler2D tex, vec2 uv, float radius, vec2 pixel_size) {
	vec2 ps = pixel_size;
	float glow = 0.0;
	float radius_safe = max(radius, 0.001);
	for (int xi = -MAX_WIDTH; xi <= MAX_WIDTH; xi++) {
		for (int yi = -MAX_WIDTH; yi <= MAX_WIDTH; yi++) {
			float fx = float(xi);
			float fy = float(yi);
			float dist = length(vec2(fx, fy));
			if (dist > radius) {
				continue;
			}
			float a = texture(tex, uv + vec2(fx, fy) * ps).a;
			float t = dist / radius_safe;
			float weight = exp(-2.0 * t * t);
			glow = max(glow, a * weight);
		}
	}
	return glow;
}

void fragment() {
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	vec4 tex = texture(TEXTURE, UV);
	vec4 sprite_color = tex * COLOR;

	if (tex.a >= ALPHA_THRESHOLD) {
		//COLOR = sprite_color;
	} else {
		float glow_field = compute_glow_field(TEXTURE, UV, width, pixel_size);
		float final_alpha = outline_color.a * glow_field * glow_alpha;
		if (final_alpha < 0.001) {
			COLOR = vec4(0.0);
		} else {
			COLOR = vec4(outline_color.rgb, final_alpha);
		}
	}
}

shader_type canvas_item;

// 色相偏移参数，范围0.0到1.0
instance uniform float hue_shift : hint_range(0.0, 1.0) = 0.0;
instance uniform float s_shift : hint_range(0.0, 1.0) = 0.0;
instance uniform float v_shift : hint_range(0.0, 1.0) = 0.0;

// RGB转HSV函数
vec3 rgb_to_hsv(vec3 rgb) {
	float r = rgb.r;
	float g = rgb.g;
	float b = rgb.b;
	
	float max_val = max(max(r, g), b);
	float min_val = min(min(r, g), b);
	float delta = max_val - min_val;
	
	vec3 hsv = vec3(0.0, 0.0, max_val);
	
	if (delta != 0.0) {
		hsv.y = delta / max_val;
		
		if (max_val == r) {
			hsv.x = mod((g - b) / delta, 6.0);
		} else if (max_val == g) {
			hsv.x = (b - r) / delta + 2.0;
		} else {
			hsv.x = (r - g) / delta + 4.0;
		}
		
		hsv.x /= 6.0;
	}
	
	return hsv;
}

// HSV转RGB函数
vec3 hsv_to_rgb(vec3 hsv) {
	float h = hsv.x * 6.0;
	float s = hsv.y;
	float v = hsv.z;
	
	float c = v * s;
	float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
	float m = v - c;
	
	vec3 rgb = vec3(0.0);
	
	if (h < 1.0) {
		rgb = vec3(c, x, 0.0);
	} else if (h < 2.0) {
		rgb = vec3(x, c, 0.0);
	} else if (h < 3.0) {
		rgb = vec3(0.0, c, x);
	} else if (h < 4.0) {
		rgb = vec3(0.0, x, c);
	} else if (h < 5.0) {
		rgb = vec3(x, 0.0, c);
	} else {
		rgb = vec3(c, 0.0, x);
	}
	
	return rgb + m;
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	// 1. 转换为HSV
	vec3 hsv = rgb_to_hsv(original_color.rgb);
	
	// 2. 核心逻辑：
	// 如果中心是白色，其 hsv.y (饱和度) 会很低。
	// 我们只改变色相，利用 "0饱和度无论怎么换色相都是白色" 的特性。
	
	// 强制改为目标色相（hue_shift），或者加上偏移
	hsv.x = mod(hue_shift, 1.0); 
	
	// 【关键修复】：不要对饱和度用 mod，改用乘法或有限的加法
	// 这样原本是 0（白色）的地方，0 乘以任何数还是 0，保持白色
	// 原本有颜色（红色）的地方，饱和度会变化
	hsv.y = clamp(hsv.y * (1.0 + s_shift), 0.0, 1.0);
	
	// 明度调整同理
	hsv.z = clamp(hsv.z + v_shift, 0.0, 1.0);
	
	// 3. 转换回RGB
	vec3 new_rgb = hsv_to_rgb(hsv);
	
	// 保持原始透明度
	COLOR = vec4(new_rgb, original_color.a);
}
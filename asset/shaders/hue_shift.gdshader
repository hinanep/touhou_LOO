shader_type canvas_item;

// 色相偏移参数，范围0.0到1.0
uniform float hue_shift : hint_range(0.0, 1.0) = 0.0;
uniform float s_shift : hint_range(0.0, 1.0) = 0.0;
uniform float v_shift : hint_range(0.0, 1.0) = 0.0;

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
	// 获取原始颜色
	vec4 original_color = texture(TEXTURE, UV);
	
	// 转换为HSV
	vec3 hsv = rgb_to_hsv(original_color.rgb);
	
	// 只改变色相，保持饱和度和明度不变
	hsv.x = mod(hsv.x + hue_shift, 1.0);
	hsv.y = mod(hsv.y + s_shift, 1.0);
	//hsv.z = mod(hsv.z + v_shift, 1.0);
	hsv.z = mod(hsv.z + v_shift, 1.0);
	// 转换回RGB
	vec3 new_rgb = hsv_to_rgb(hsv);
	
	// 输出结果，保持原始透明度
	COLOR.rgb = new_rgb;
} 
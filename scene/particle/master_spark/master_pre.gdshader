shader_type canvas_item;

// --- 可调节参数 ---
uniform float time_scale = 0.5;             // 整体能量流动速度
uniform float rainbow_freq = 3.0;           // 彩虹色的密度
uniform float cloud_speed = 0.2;            // 云雾流动速度
uniform float cloud_density = 3.0;          // 云雾密度/细节程度
uniform float cloud_intensity = 0.6;        // 云雾对光束形状的影响强度
uniform float transparency_threshold = 0.4; // 透明度阈值 (值越高，透明区域越多)

// Godot 4.x 内置 HSV 转 RGB 函数
vec3 hsv_to_rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// 简单的伪随机噪声函数
float hash12(vec2 p) {
    vec3 p3  = fract(p.xyx * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float perlin_noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 fp = fract(p);
    fp = fp * fp * (3.0 - 2.0 * fp); // Smoothstep

    float n00 = hash12(ip);
    float n10 = hash12(ip + vec2(1.0, 0.0));
    float n01 = hash12(ip + vec2(0.0, 1.0));
    float n11 = hash12(ip + vec2(1.0, 1.0));

    float x0 = mix(n00, n10, fp.x);
    float x1 = mix(n01, n11, fp.x);
    return mix(x0, x1, fp.y);
}
// 【修正后】的旋转函数
mat2 rotate(float angle){
    // Godot 的 GLSL 需要通过两个列向量 (vec2) 来构造 mat2。
    // 这是标准的2D旋转矩阵的列向量表示法。
    vec2 col1 = vec2(cos(angle), sin(angle));
    vec2 col2 = vec2(-sin(angle), cos(angle));
    return mat2(col1, col2);
}

void fragment() {
    // 1. 创建光束的基础形状 (中间亮，两边暗)
    float base_beam_shape = 1.0 - abs(UV.y - 0.5) * 2.0;
    base_beam_shape = smoothstep(0.0, 1.0, base_beam_shape);

    // 2. 生成流动的云雾噪声
    vec2 noise_uv = UV * cloud_density;
    // 【修改点 1】将 += 修改为 -=，使其与下面的彩虹色流动方向一致
    noise_uv.x -= TIME * cloud_speed ;
	noise_uv.y += TIME * cloud_speed * (0.5);

    float cloud1 = perlin_noise(noise_uv * 1.0);
	float cloud2 = perlin_noise(noise_uv - TIME * cloud_speed * 0.5);

	float cloud_pattern = (0.67*cloud1) ;
    cloud_pattern = pow(cloud_pattern, 2.0);
    // 【修改点 2】使用 uniform 变量来控制透明度阈值
    cloud_pattern = smoothstep(transparency_threshold, 0.8, cloud_pattern);

    // 3. 将云雾噪声应用到光束形状上
    float final_beam_shape = mix(base_beam_shape, cloud_pattern, cloud_intensity);
    final_beam_shape = clamp(final_beam_shape, 0.0, 1.0);

    // 4. 创建流动的能量纹理
    float energy_flow_noise = (sin(UV.x * 20.0 - TIME * time_scale) + cos(UV.y * 10.0 - TIME * time_scale)) * 0.5;

    // 5. 创建彩虹色
    // (注意这里的 - TIME 决定了流动方向)
    float hue = fract(UV.x * rainbow_freq - TIME * time_scale * 0.5);
    vec3 rainbow_color = hsv_to_rgb(vec3(hue, 0.8, 1.0));

    // 6. 组合所有元素
    vec3 final_color_rgb = mix(rainbow_color, vec3(1.0, 1.0, 0.9), energy_flow_noise * 0.2);

    // 7. 应用最终形状和透明度
    COLOR = vec4(final_color_rgb, final_beam_shape);
}
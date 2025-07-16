shader_type canvas_item;

// uniform 变量会显示在检查器中，方便我们调整
// hint_range 让它在编辑器里变成一个滑块
uniform float start_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float end_alpha : hint_range(0.0, 1.0) = 0.0;
uniform bool fade_from_right = false;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);

    // 根据 fade_from_right 决定渐变进度
    float fade_progress = UV.x;
    if (fade_from_right) {
        fade_progress = 1.0 - UV.x;
    }

    // 使用 mix() 函数根据进度在 start_alpha 和 end_alpha 之间进行线性插值
    float new_alpha = mix(start_alpha, end_alpha, fade_progress);

    // 将新计算的 alpha 应用到原始颜色上
    COLOR = original_color;
    COLOR.a *= new_alpha;
}
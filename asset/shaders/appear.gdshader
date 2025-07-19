// 定义这是一个用于2D对象的着色器
shader_type canvas_item;

// "uniform" 变量可以在外部（如GDScript或AnimationPlayer）被访问和修改
// progress 控制动画进度 (0.0=完全隐藏, 1.0=完全显示)
uniform float progress : hint_range(0.0, 1.0) = 0.0;
// feather 控制边缘的羽化/模糊程度，让过渡更柔和
uniform float feather : hint_range(0.0, 0.5) = 0.1;

void fragment() {

    // 获取当前像素的原始颜色
    vec4 original_color = texture(TEXTURE, UV);
	
    // 1. 计算当前像素的UV坐标离水平中心(0.5)的距离。
    //    abs()取绝对值，所以左右两边都会得到一个从0.0(中心)到0.5(边缘)的值。
    float dist_from_center = abs(UV.x - 0.5);

    // 2. 我们希望从边缘(距离最大)向中心(距离最小)显示。
    //    所以我们用 0.5 减去这个距离，得到一个“显示优先级”的值。
    //    这个值在边缘是0.0，在中心是0.5。
    float reveal_value = 0.5 - dist_from_center;

    // 3. 使用 smoothstep 函数根据 progress 计算最终的 alpha 值。
    //    这会创造一个平滑的过渡，而不是一个生硬的边缘。
    //    当 progress 大于 reveal_value 时，像素开始变得不透明。
    //    feather 参数控制了这个过渡带的宽度。
    float alpha = smoothstep(reveal_value - feather, reveal_value + feather, progress * 0.5);

    // 4. 将计算出的 alpha 值应用到原始颜色的 alpha 通道上。
    //    乘以 original_color.a 可以保留纹理本身的透明区域。
    COLOR = original_color;
	if(progress < 1.0){
		COLOR.a *= alpha;
	}
    
}
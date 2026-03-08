shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float spread : hint_range(0.0, 3.0) = 0.6;    // 爆炸强度
uniform float gravity : hint_range(0.0, 5.0) = 2.0;  // 重力强度
uniform float grid_size : hint_range(1.0, 100.0) = 20.0; // 碎片密度

// 随机函数，用于给不同碎片增加一点点差异化
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
uniform bool is_boob = false; // 碎片密度
void fragment() {
   	if(is_boob){
		vec2 grid_uv = (floor(UV * grid_size) + 0.5) / grid_size;
    
	    // 2. 计算离心方向 (从中心指向格子的向量)
	    vec2 center = vec2(0.5, 0.5);
	    vec2 dir = grid_uv - center;
	    
	    // 加上一点随机扰动，防止爆炸看起来像一个完美的圆
	    float r = rand(grid_uv);
	    dir += (vec2(r) - 0.5) * 0.5; 
	    
	    // 3. 计算位移
	    // 水平和初始向上的力：dir * progress
	    vec2 velocity = dir * progress * spread * 5.0;
	    
	    // 重力影响：随着时间(progress)平方级增加 Y 轴位移
	    float gravity_effect = progress * progress * gravity;
	    
	    // 总位移：离心力 + 重力
	    vec2 offset = velocity;
	    offset.y += gravity_effect; // Y轴向下增加
	    
	    // 4. 采样原图
	    vec2 target_uv = UV - offset;
	    vec4 color = texture(TEXTURE, target_uv);
	    
	    // 5. 边界剪裁：只显示当前格子范围内的内容，防止碎片互相重叠
	    // 先计算采样点属于哪个格子
	    vec2 target_grid_uv = (floor(target_uv * grid_size) + 0.5) / grid_size;
	    
	    // 如果采样的点不在原来的格子里，或者是越界了，就裁掉
	    if (distance(target_grid_uv, grid_uv) > 0.1 / grid_size || 
	        target_uv.x < 0.0 || target_uv.x > 1.0 || target_uv.y < 0.0 || target_uv.y > 1.0) {
	        color.a = 0.0;
	    }
	    
	    // 随进度淡出
	    color.a *= (1.0 - pow(progress, 3.0));
	    
	    COLOR = color;
	}
}
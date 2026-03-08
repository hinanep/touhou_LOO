shader_type canvas_item;

instance uniform float width:hint_range(0.0,30.0);
uniform vec4 outline_color : source_color;


uniform float radius:hint_range(0.0,2.0) = 0.5;//取样半径（基于像素）
uniform int sampleCount:hint_range(1, 8) = 4;//取样次数
uniform float grayLimit :hint_range(0.0, 1.0) = 0.3;//取样最低灰度
instance uniform float brightness :hint_range(0.0, 1.0)= 0.5;//模糊亮度

instance uniform float progress : hint_range(0.0, 1.0) = 0.0; // 长按进度 0-1
instance uniform float shake_strength = 0.0;                 // 抖动强度

instance uniform float boob_progress : hint_range(0.0, 1.0) = 0.0;
uniform float spread : hint_range(0.0, 3.0) = 0.6;    // 爆炸强度
uniform float gravity : hint_range(0.0, 5.0) = 2.0;  // 重力强度
uniform float grid_size : hint_range(1.0, 100.0) = 20.0; // 碎片密度
instance uniform bool is_boob = false; // 碎片密度
// 随机函数，用于给不同碎片增加一点点差异化
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
// 随机函数用于产生抖动
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}
vec4 limitGrayColor(vec4 color,float limit){

if(limit <=0.0)//没限制，输入什么就输出什么
return color;

//计算灰度
float gray = dot(color.rgb,vec3(0.299, 0.587, 0.114));

if (gray<=limit){//灰度小于限制，就返回透明颜色
return vec4(0.0);

}else //不然就保留该颜色
return color;

}

void vertex() {
	// 实现随机抖动逻辑
	if (shake_strength > 0.0) {
		VERTEX.x += (random(vec2(TIME, 0.0)) - 0.5) * shake_strength;
		VERTEX.y += (random(vec2(0.0, TIME)) - 0.5) * shake_strength;
	}
}

void fragment(){


    float size = width * 1.0 / float(textureSize(TEXTURE,0).x);
    vec4 sprite_color = texture(TEXTURE,UV);
	float alpha;
	if( sprite_color.a > 0.0)
    	alpha = -8.0 * 1.0;
	else alpha = 0.0;
    alpha += texture(TEXTURE,UV + vec2(0.0,-size)).a;
    alpha += texture(TEXTURE,UV + vec2(size,-size)).a;
    alpha += texture(TEXTURE,UV + vec2(size,0)).a;
    alpha += texture(TEXTURE,UV + vec2(size,size)).a;
    alpha += texture(TEXTURE,UV + vec2(0.0,size)).a;
    alpha += texture(TEXTURE,UV + vec2(-size,size)).a;
    alpha += texture(TEXTURE,UV + vec2(-size,0.0)).a;
    alpha += texture(TEXTURE,UV + vec2(-size,-size)).a;
    vec4 final_color = mix(sprite_color,outline_color,clamp(alpha,0.0,1.0));
    COLOR = vec4(final_color.rgb,clamp(abs(alpha)*outline_color.a+ sprite_color.a ,0.0,1.0));

vec2 ps = TEXTURE_PIXEL_SIZE;//像素大小

vec4 col = vec4(0.0);//最终输出的颜色

for(int i = 1;i<=sampleCount;i++){

//**当前为向8个方向取样，时间复杂度为O(n)，模糊效果不是特别好,尤其是对角
//当然你也可以向外n*n个格子取样，不过时间复杂度是O(n^2),模糊效果较为精确
//网上那些n+n的取样方式是对一张图处理1次后把图提取出来再处理1次，要配合底层代码来写的。
col+=limitGrayColor(
texture(TEXTURE,UV + vec2(0,-radius)*ps*float(i)),grayLimit);
col+=limitGrayColor(
texture(TEXTURE,UV + vec2(0,radius)*ps*float(i)),grayLimit);
col+=limitGrayColor(
texture(TEXTURE,UV + vec2(-radius,0)*ps*float(i)),grayLimit);
col+=limitGrayColor(
texture(TEXTURE,UV + vec2(radius,0)*ps*float(i)),grayLimit);
col+=limitGrayColor(
texture(TEXTURE,UV + vec2(radius,radius)*ps*float(i)),grayLimit);
col+=limitGrayColor(
texture(TEXTURE,UV + vec2(radius,-radius)*ps*float(i)),grayLimit);
col+=limitGrayColor(
texture(TEXTURE,UV + vec2(-radius,radius)*ps*float(i)),grayLimit);
col+=limitGrayColor(
texture(TEXTURE,UV + vec2(-radius,-radius)*ps*float(i)),grayLimit);}

col/=(8.0*float(sampleCount));
vec4 effect_color = col * brightness + COLOR;

	COLOR.rgb = effect_color.rgb;
	
	
	
// 从下往上变红：1.0-UV.y 会从底部(1.0)到顶部(0.0)计算
    // 如果当前的进度大于高度占比，则混入红色
    float mask = step(1.0 - progress, UV.y);
    
    // 混合原始颜色和红色，长按越多红得越深
    vec3 red_tint = mix(COLOR.rgb, vec3(1.0, 0.0, 0.0), 0.7);   
    COLOR.rgb = mix(COLOR.rgb, red_tint, mask);
	
	
	if(is_boob){
		vec2 grid_uv = (floor(UV * grid_size) + 0.5) / grid_size;
    
	    // 2. 计算离心方向 (从中心指向格子的向量)
	    vec2 center = vec2(0.5, 0.5);
	    vec2 dir = grid_uv - center;
	    
	    // 加上一点随机扰动，防止爆炸看起来像一个完美的圆
	    float r = rand(grid_uv);
	    dir += (vec2(r) - 0.5) * 0.5; 
	    
	    // 3. 计算位移
	    // 水平和初始向上的力：dir * boob_progress
	    vec2 velocity = dir * boob_progress * spread * 5.0;
	    
	    // 重力影响：随着时间(boob_progress)平方级增加 Y 轴位移
	    float gravity_effect = boob_progress * 0.5 * gravity;
	    
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
	    color.a *= 1.0 * (1.0 - boob_progress);
	    
	    COLOR = color;
	}
	
}


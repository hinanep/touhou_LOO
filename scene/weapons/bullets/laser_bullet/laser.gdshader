shader_type canvas_item;

uniform float width: hint_range(1.0, 1.5) = 1.0;
uniform float radius:hint_range(0.0,2.0) = 0.5;//取样半径（基于像素）
uniform int sampleCount:hint_range(1, 8) = 4;//取样次数
uniform float grayLimit :hint_range(0.0, 1.0) = 0.3;//取样最低灰度
uniform float brightness :hint_range(0.0, 1.0)= 0.5;//模糊亮度

varying vec2 realUV;

vec4 limitGrayColor(vec4 color,float limit){
	if(limit <=0.0)//没限制，输入什么就输出什么
		return color;
	//计算灰度
	float gray = dot(color.rgb,vec3(0.299, 0.587, 0.114));
	if (gray<=limit){//灰度小于限制，就返回透明颜色
		return vec4(0.0);
	} else //不然就保留该颜色
		return color;
}

void vertex() {
	VERTEX += (UV * 2.0 - 1.0) * width;
}


void fragment(){

	vec2 ps = TEXTURE_PIXEL_SIZE;//像素大小

	vec4 col = vec4(0.0);//最终输出的颜色
	
	vec2 real_uv = UV;// / width;

	for(int i = 1;i<=sampleCount;i++){

		//**当前为向8个方向取样，时间复杂度为O(n)，模糊效果不是特别好,尤其是对角
		//当然你也可以向外n*n个格子取样，不过时间复杂度是O(n^2),模糊效果较为精确
		//网上那些n+n的取样方式是对一张图处理1次后把图提取出来再处理1次，要配合底层代码来写的。
		col+=limitGrayColor(
			texture(TEXTURE,real_uv + vec2(0,-radius)*ps*float(i)),grayLimit);
		col+=limitGrayColor(
			texture(TEXTURE,real_uv + vec2(0,radius)*ps*float(i)),grayLimit);
		col+=limitGrayColor(
			texture(TEXTURE,real_uv + vec2(-radius,0)*ps*float(i)),grayLimit);
		col+=limitGrayColor(
			texture(TEXTURE,real_uv + vec2(radius,0)*ps*float(i)),grayLimit);
		col+=limitGrayColor(
			texture(TEXTURE,real_uv + vec2(radius,radius)*ps*float(i)),grayLimit);
		col+=limitGrayColor(
			texture(TEXTURE,real_uv + vec2(radius,-radius)*ps*float(i)),grayLimit);
		col+=limitGrayColor(
			texture(TEXTURE,real_uv + vec2(-radius,radius)*ps*float(i)),grayLimit);
		col+=limitGrayColor(
			texture(TEXTURE,real_uv + vec2(-radius,-radius)*ps*float(i)),grayLimit);
	}
	col/=(8.0*float(sampleCount));
	COLOR = col*brightness+texture(TEXTURE,real_uv);

}

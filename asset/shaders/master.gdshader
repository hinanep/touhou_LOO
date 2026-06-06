/*
 * 作用：3D 空间材质，按顶点坐标采样渐变贴图作为固有色，配合边缘光与顶点位置驱动的自发光。
 * 推荐文件名：gradient_emissive_3d.gdshader
 */
shader_type spatial;

uniform sampler2D gradient_color :source_color;
uniform sampler2D noise;
varying vec2 custom_uv;
void vertex() {
	custom_uv =vec2(clamp(VERTEX.x,0.1,10.0),clamp(VERTEX.y,-10.0,10.0));
	//custom_uv =vec2(0.0,clamp(VERTEX.y,-10.0,10.0));
	//COLOR.y = NODE_POSITION_WORLD.y;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 out_color = texture(gradient_color,custom_uv).rgb;

  RIM = 0.2;
  METALLIC = 0.0;
  ROUGHNESS = 0.01;
  ALBEDO = out_color;
	EMISSION = vec3(0.1, 0.1, 0.1);
	EMISSION.x *= clamp(abs(VERTEX.x),0.1,1);
	EMISSION *= clamp(abs(VERTEX.y),0.0,1);

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;
uniform sampler2D mainTexture;
varying vec2 custom_uv;

uniform float distor_modi :hint_range(0.0, 1.0)= 0.1;//模糊亮度
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 disp = texture(mainTexture,UV).xy;
	disp = (2.0*disp) - 1.0;
	disp *= distor_modi;
	COLOR.rgb = textureLod(screen_texture,SCREEN_UV+disp,0.0).rgb;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;
uniform vec4 glow_color:source_color = vec4(0.2,0.6,0.3,1.0);
uniform float glow_power :hint_range(0.0, 8.0, 0.1) = 2.0;
uniform float glow_shift :hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float glow_radius :hint_range(1.0, 10.0, 1.0) = 1.0;
vec4 screen(vec4 base, vec4 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}
void fragment() {
	vec4 pixel = texture(TEXTURE,UV);

	if(pixel.a < 0.1){
		pixel.a = 0.0;
	}
	pixel = glow_color * pixel.a;
	vec4 glow =  glow_color * pixel.a ;

	COLOR = screen(pixel,glow);
	//COLOR = target;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

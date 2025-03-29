shader_type canvas_item;
varying vec2 custom_uv;
uniform sampler2D gradient_color :source_color;
void vertex() {
	custom_uv =vec2(clamp(VERTEX.x,0.0,10.0),clamp(VERTEX.y,-10.0,10.0));
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb *= texture(gradient_color,custom_uv).rgb;
	COLOR.rgb *= clamp(5.0-5.0*abs(custom_uv.y),1.2,10.0);
	
	//COLOR = vec4(1.,1.,1.,1.);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

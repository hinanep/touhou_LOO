shader_type canvas_item;
varying vec2 custom_uv;
uniform sampler2D gradient_color :source_color;
void vertex() {
	custom_uv =vec2(clamp(VERTEX.x,0.0,10.0),clamp(VERTEX.y,-10.0,10.0));
	// Called for every vertex the material is visible on.
}
float addi(){
	return sin(TIME)+1.0;
}
vec3 sample_color(float cordi){
	cordi += 4.5;
	cordi /= 20.0;
	cordi -= TIME*0.5;
	cordi = fract(cordi);

	return texture(gradient_color,vec2(cordi,0.0)).rgb;
}
void fragment() {

	COLOR.rgb = mix(COLOR.rgb,sample_color(custom_uv.x)*0.9,0.7); 
	//COLOR.rgb *=7.0-1.0*abs(custom_uv.y);
	//COLOR.rgb *=7.0-3.0*abs(custom_uv.y)*clamp(0.9/(custom_uv.x+2.7)*2.0,0.1,2.0);
	COLOR.rgb *= clamp(2.8-1.0*abs(custom_uv.y)*clamp(0.9/(custom_uv.x+2.7)*2.0,0.1,2.0),0.2,2.5);

	//COLOR = vec4(1.,1.,1.,1.);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

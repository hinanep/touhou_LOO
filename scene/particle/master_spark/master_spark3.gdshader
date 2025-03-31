shader_type canvas_item;
uniform sampler2D mainTexture;
varying vec2 custom_uv;
void vertex() {
	custom_uv = vec2(VERTEX.x+TIME,VERTEX.y+0.5);
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb *= texture(mainTexture,custom_uv).rgb;
	COLOR.a *= texture(mainTexture,custom_uv).a;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

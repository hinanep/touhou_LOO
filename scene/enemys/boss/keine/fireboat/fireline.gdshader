shader_type canvas_item;
instance uniform float phase1 :hint_range(0.0, 1.0)= 0.0;
instance uniform float phase2 :hint_range(0.0, 1.0)= 0.0;



void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

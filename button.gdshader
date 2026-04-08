shader_type canvas_item;
uniform sampler2D tex;
uniform float bright = 0.5;
uniform vec3 button_color = vec3(0.1,0.2,0.2);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 res = bright * button_color;
	float a = texture(tex,UV).w;
	
	COLOR = vec4(res,a);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

uniform float width:hint_range(0.0,30.0);
uniform vec4 outline_color : source_color;

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
}
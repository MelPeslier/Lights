shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;

group_uniforms Waves;
uniform float wave_radius;
uniform float wave_current_radius;
uniform float wave_inner_radius;
uniform vec2 wave_origin;
uniform sampler2D mask : hint_default_black, repeat_disable;

float stroke(float _edge, float _aim, float _width){
	return step(_edge, _aim + _width * 0.5) - step(_edge, _aim - _width * 0.5);
}

void fragment() {
	vec2 uv = UV ;
	uv = uv * 2.0 - 1.0;
	//uv *= 0.5625;
	vec4 tex = texture( screen_tex, UV );
	// divide length(...) by  radius / screen.x
	float circle_sdf = length(uv - wave_origin ) / wave_radius ;

	float outer_line = stroke(circle_sdf, wave_current_radius, 0.1);
	float outer_edge = step(circle_sdf, wave_current_radius);
	float inner_edge = step(wave_inner_radius, circle_sdf);
	float inner_part = min(inner_edge, outer_edge);
	vec2 uv_mask = (uv - wave_origin + 1.0) / 2.0 ;

	// make what's outdise black per default
	float mask_tex = texture( mask, uv_mask ).r;
	mask_tex = mix(0.0, mask_tex,
		step(uv.x, 1.0) * step(-1.0, uv.x) *
		step(uv.y, 1.0) * step(-1.0, uv.y)
	);

	//COLOR.rgb = vec3(circle_sdf);
	//COLOR.rgb = vec3( outer_line );
	//COLOR.rgb = vec3( outer_edge );
	//COLOR.rgb = vec3( inner_edge );
	COLOR.rgb = vec3( inner_part * mask_tex );
	//COLOR.rgb = vec3( mask_tex );
	COLOR.a = step(inner_part * mask_tex, outer_line * mask_tex) ;

}


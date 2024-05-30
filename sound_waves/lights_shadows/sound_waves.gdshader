shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;

group_uniforms Waves;
uniform float wave_radius;
uniform float wave_outer_line_coef = 0.05;
uniform float wave_current_radius;
uniform float wave_inner_radius;
uniform vec2 wave_origin;
uniform vec3 wave_color : source_color = vec3(1.0);
uniform sampler2D mask : hint_default_black, repeat_disable;

uniform sampler2D inner_noise : hint_default_black;

uniform sampler2D darkness_noise : hint_default_black;


float stroke(float _edge, float _aim, float _width){
	return step(_edge, _aim + _width * 0.5) - step(_edge, _aim - _width * 0.5);
}

float smooth_stroke(float _edge, float _aim, vec2 _width){
	float inner = smoothstep(_edge, _edge + _width.x, _aim);
	float outer = smoothstep(_edge - _width.y, _edge, _aim);
	return outer - inner;
}


void fragment() {
	vec2 uv = UV ;
	uv = uv * 2.0 - 1.0;

	vec4 tex = texture( screen_tex, SCREEN_UV ); // maping  our original  image to the screen_uv

// * Captured Mask * : Darken non reachable areas (based on previous light mask capture and wave radius)
	vec2 uv_mask = ( (uv - wave_origin) / wave_radius + 1.0) / 2.0 ; // keep it at origin location and keep the right aspect
	float baked_mask = texture( mask, uv_mask ).r;
	baked_mask = mix(0.0, baked_mask,
		step(uv.x, wave_radius) * step(-wave_radius, uv.x) *
		step(uv.y, wave_radius) * step(-wave_radius, uv.y)
	); // make what's outdise of the mask texture black per default of the texture : no reapeat and so we want black
	// Not necessary as what's outside won't ever be revealed.

// * World mask * : Circle visible
	float circle_sdf = length(uv - wave_origin ) / wave_radius ; // divide length(...) by  radius / screen.x
	float outer_edge = step(circle_sdf, wave_current_radius);
	//float inner_edge = step(wave_inner_radius, circle_sdf);
	float inner_edge = smoothstep(circle_sdf, 0.0, wave_inner_radius);
	inner_edge = pow(inner_edge, 0.5);
	float inner_part = min(inner_edge, outer_edge);
	float world_mask = inner_part;

	// Mask inner part with a noise

	vec3 world_output = tex.rgb * world_mask * baked_mask * wave_color;

// * Outer Line *
	//float outer_line = stroke(circle_sdf, wave_current_radius - wave_outer_line_coef*0.5, wave_outer_line_coef);
	float outer_line_mask = pow( smooth_stroke(circle_sdf, wave_current_radius , wave_outer_line_coef * vec2(1.0, 0.25)), 2.0);
	float line_fade_out = smoothstep(1.0, 0.75, wave_current_radius);
	vec3 wave_output = wave_color * outer_line_mask * baked_mask * line_fade_out;



// We suppose that everthin is white, and so we can give it the color we want :)
// Even make itreact differently if the base color of something is only red, then only waves with red will show it / make it brigther
	COLOR.rgb = mix(world_output, wave_output, outer_line_mask * line_fade_out);
	//COLOR.rgb = world_output + wave_output; // same .???
	//COLOR.rgb = vec3( fade_out );
}


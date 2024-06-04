shader_type canvas_item;

uniform float _aim : hint_range(0.0, 0.05, 0.0001) = 0.005;


void fragment() {
	// Conversion des UV d'écran en position SDF
	vec2 sdf_pos = screen_uv_to_sdf(SCREEN_UV);
	// Récupération de la valeur SDF
	float sdf_value = texture_sdf(sdf_pos);

	// Calcul de la normale à partir de la texture SDF
	vec2 sdf_normal = texture_sdf_normal(sdf_pos);

	// Conversion de la position SDF en UV d'écran (pour démonstration)
	vec2 new_screen_uv = sdf_to_screen_uv(sdf_pos);

	// Utilisation des valeurs SDF pour déterminer la couleur
	//COLOR.rg = step( ( abs(sdf_normal)), vec2(_aim)); // Affiche la valeur SDF comme couleur
	COLOR.r = step( sdf_value, _aim); // Affiche la valeur SDF comme couleur
	COLOR.r = 1.0-sdf_value * _aim; // Affiche la valeur SDF comme couleur
	COLOR.r = step(sdf_value,0.0) ; // Affiche la valeur SDF comme couleur
	float inside_sdf = step(sdf_value, 0.0) ; // Inside
	float outside_sdf = step(0.0, sdf_value) ; // Outside
	COLOR.r = inside_sdf * (1.0-sdf_value) * _aim;
	COLOR.g = outside_sdf * (sdf_value) * _aim;
	COLOR.g *= step(COLOR.g, 0.3);
	COLOR.b = 0.0;
	COLOR.rgb = vec3( step(length(UV - vec2(0.5)), 0.4) );
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

// Parámetros que controlamos desde Godot (Inspector o Código)
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Blanco por defecto
uniform float line_thickness : hint_range(0.0, 10.0) = 0.0;          // Grosor que cambia tu script

void fragment() {
	// Obtenemos el tamaño de un píxel en coordenadas de textura (UV)
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	
	// Muestreamos los 4 pìxeles vecinos (arriba, abajo, izquierda, derecha)
	float alpha = texture(TEXTURE, UV).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;  // Arriba
	alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a; // Abajo
	alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;  // Derecha
	alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a; // Izquierda
	
	// Obtenemos el color original del sprite
	vec4 sprite_color = texture(TEXTURE, UV);
	
	// Si sumando los vecinos hay opacidad, pero el píxel original es transparente, pintamos contorno
	if (sprite_color.a == 0.0 && alpha > 0.0) {
		COLOR = outline_color;
	} else {
		COLOR = sprite_color;
	}
}
shader_type canvas_item;

void fragment() {
	// 1. Leemos cómo es el píxel original de Blue
	vec4 color_original = texture(TEXTURE, UV);
	
	// 2. Lo pintamos de blanco puro (RGB = 1.0, 1.0, 1.0), pero 
	// conservamos su transparencia original (Alpha) para no pintar un cuadrado.
	COLOR = vec4(1.0, 1.0, 1.0, color_original.a);
}
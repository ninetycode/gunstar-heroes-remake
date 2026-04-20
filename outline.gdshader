shader_type canvas_item;

// Parámetros que vamos a modificar desde el script o el inspector
uniform vec4 line_color : source_color = vec4(0.0, 1.0, 0.8, 1.0); // Turquesa
uniform float line_thickness : hint_range(0.0, 10.0) = 0.0; // En 0 está apagado

void fragment() {
    // Leemos el tamaño de los píxeles de la textura
    vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
    
    // Chequeamos los píxeles vecinos en todas las direcciones
    float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    outline = min(outline, 1.0);

    // Pintamos el borde sin tapar el dibujo original
    vec4 color = texture(TEXTURE, UV);
    COLOR = mix(color, line_color, outline - color.a);
}

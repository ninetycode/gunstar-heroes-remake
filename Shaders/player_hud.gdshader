shader_type canvas_item;

uniform vec4 brillo_color : source_color = vec4(1.0, 1.0, 1.0, 0.5); // Blanco con transparencia
uniform float velocidad : hint_range(0.0, 5.0) = 1.5;
uniform float ancho : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    // Tomamos el color original de la barra (el azul que ya tenés)
    vec4 color_original = texture(TEXTURE, UV);
    
    // Si el pixel es transparente (fuera de la barra), no hacemos nada
    if (color_original.a < 0.1) {
        discard;
    }

    // --- LA MAGIA DEL BARRIDO ---
    // Usamos el tiempo y la posición X (UV.x) para crear la línea
    // Como tu barra se llena de derecha a izquierda, esto va a fluir prolijo
    float linea = smoothstep(0.0, 1.0, sin(UV.x * 2.0 + TIME * velocidad));
    
    // Creamos una máscara para que la línea sea delgada
    float mascara_brillo = step(1.0 - ancho, linea);
    
    // Mezclamos el azul original con el blanco del brillo
    COLOR = mix(color_original, brillo_color, mascara_brillo * brillo_color.a);
    
    // Mantener la transparencia original de la textura
    COLOR.a = color_original.a;
}
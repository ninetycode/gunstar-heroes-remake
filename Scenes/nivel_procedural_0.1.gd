extends Node2D

# 1. Configuración de rutas
@export_group("Configuración de Archivos")
@export var ruta_niveles: String = "res://Scenes/" 
@export var habitaciones_nombres: Array[String] = [
	"Room 1-1", "Room 1-2", "Room 1-3", 
	"Room 1-4", "Room 1-5", "Room 1-6"
]
@export var nombre_boss: String = "RoomBoss"

# 2. Variables de control
var ultima_posicion_salida: Vector2 = Vector2.ZERO
var es_primera_sala: bool = true

func _ready() -> void:
	# Limpieza de nodos viejos (protegiendo los esenciales)
	for child in get_children():
		if child.name == "GunstarBlue" or child is CanvasLayer or child.name == "Background" or child.name == "Camera2D":
			continue 
		if child is Node2D:
			child.queue_free()
	
	await get_tree().process_frame
	ultima_posicion_salida = Vector2.ZERO 
	generar_nivel_procedural()


func generar_nivel_procedural():
	habitaciones_nombres.shuffle()
	
	var blue = get_node_or_null("GunstarBlue")
	es_primera_sala = true # Reiniciamos el flag antes del bucle
	
	for i in range(habitaciones_nombres.size()):
		var nombre = habitaciones_nombres[i]
		var ruta_completa = ruta_niveles + nombre + ".tscn"
		
		if ResourceLoader.exists(ruta_completa):
			var escena = load(ruta_completa)
			var nueva_sala = coser_habitacion(escena)
			
			# Si es la primera sala, posicionamos al jugador y reseteamos la cámara
			if i == 0 and blue:
				var entrada = nueva_sala.get_node_or_null("Entrada")
				if entrada:
					blue.global_position = entrada.global_position
					
					# Centramos la cámara directo en el jugador para evitar desajustes iniciales
					var camara = get_node_or_null("Camera2D")
					if camara:
						camara.global_position = blue.global_position
						
						# --- FIX: Le ponemos una "pared" a la visión de la cámara ---
						# Esto evita que encuadre el vacío a la izquierda del nivel
						camara.limit_left = int(nueva_sala.position.x)
			
			es_primera_sala = false # Las siguientes salas desactivan este flag
		else:
			push_warning("No se encontró: " + ruta_completa)

	# Instanciar el Boss al final
	var ruta_boss = ruta_niveles + nombre_boss + ".tscn"
	if ResourceLoader.exists(ruta_boss):
		coser_habitacion(load(ruta_boss))


func coser_habitacion(recurso_escena: PackedScene) -> Node2D:
	var instancia = recurso_escena.instantiate()
	var entrada = instancia.get_node_or_null("Entrada")
	
	if entrada:
		if es_primera_sala:
			# REGLA PARA LA PRIMERA SALA: Solo alineamos el eje X horizontal.
			# Mantenemos Y = 0 local para que la sala conserve su altura de diseño nativa del editor.
			instancia.position.x = 0 - entrada.position.x
			instancia.position.y = 0
		else:
			# REGLA PARA LAS SIGUIENTES: Costura total (X e Y) acoplándose a la salida anterior.
			instancia.position = ultima_posicion_salida - entrada.position
	else:
		instancia.position = ultima_posicion_salida
		
	# Añadimos la habitación al árbol de nodos una vez posicionada correctamente
	add_child(instancia)
	
	# Guardamos la salida global para la próxima costura
	var salida = instancia.get_node_or_null("Salida")
	if salida:
		ultima_posicion_salida = salida.global_position
		
	return instancia

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

func _ready() -> void:
	# REVISIÓN CRÍTICA: Solo borramos lo que NO sea el jugador o la UI
	for child in get_children():
		if child.name == "GunstarBlue" or child is CanvasLayer:
			continue # Saltamos al jugador y al HUD para que no desaparezcan
		
		# Si es una instancia de una habitación previa, la borramos
		if child is Node2D:
			child.queue_free()
	
	await get_tree().process_frame
	
	# Reiniciamos la posición de costura al origen (o donde esté Blue)
	ultima_posicion_salida = Vector2.ZERO 
	
	generar_nivel_procedural()

func generar_nivel_procedural():
	habitaciones_nombres.shuffle()
	
	# 3. Posicionar a Blue al inicio de la primera habitación
	var blue = get_node_or_null("GunstarBlue")
	
	for i in range(habitaciones_nombres.size()):
		var nombre = habitaciones_nombres[i]
		var ruta_completa = ruta_niveles + nombre + ".tscn"
		
		if ResourceLoader.exists(ruta_completa):
			var escena = load(ruta_completa)
			var nueva_sala = coser_habitacion(escena)
			
			# Si es la primera sala, movemos a Blue a su "Entrada"
			if i == 0 and blue:
				var entrada = nueva_sala.get_node_or_null("Entrada")
				if entrada:
					blue.global_position = entrada.global_position
		else:
			push_warning("No se encontró: " + ruta_completa)

	# Instanciar el Boss
	var ruta_boss = ruta_niveles + nombre_boss + ".tscn"
	if ResourceLoader.exists(ruta_boss):
		coser_habitacion(load(ruta_boss))

func coser_habitacion(recurso_escena: PackedScene) -> Node2D:
	var instancia = recurso_escena.instantiate()
	add_child(instancia)
	
	var entrada = instancia.get_node_or_null("Entrada")
	var salida = instancia.get_node_or_null("Salida")
	
	if entrada and salida:
		instancia.global_position = ultima_posicion_salida - entrada.position
		ultima_posicion_salida = instancia.global_position + salida.position
	else:
		instancia.global_position = ultima_posicion_salida
		
	return instancia

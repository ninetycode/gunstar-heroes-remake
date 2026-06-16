extends Node

var habitacion_actual: int = 0
var ruta_generada: Array[String] = []

@export_category("Mazo de Habitaciones")
@export var pool_habitaciones: Array[String] # Acá arrastrás las escenas de Facu
@export var jefe_final: String               # La ruta a la escena del jefe final

@export_category("Configuración de Nivel")
@export var cantidad_salas_antes_del_boss: int = 8 # <-- Expuesto para que lo manejes desde el Inspector

func iniciar_nivel():
	habitacion_actual = 0
	ruta_generada.clear()
	
	# 1. Armamos el mazo temporal y lo mezclamos
	var temp_pool = pool_habitaciones.duplicate()
	temp_pool.shuffle()
	
	# 2. Elegimos las salas normales previas al jefe
	for i in range(cantidad_salas_antes_del_boss):
		ruta_generada.append(temp_pool[i % temp_pool.size()])
		
	# 3. Ponemos la Sala Final: Jefe
	ruta_generada.append(jefe_final)
	
	# 4. ¡Arrancamos el viaje!
	print("Nivel generado: ", ruta_generada)
	avanzar_habitacion()

func avanzar_habitacion():
	if habitacion_actual < ruta_generada.size():
		var siguiente_escena = ruta_generada[habitacion_actual]
		habitacion_actual += 1
		TransitionManager.viajar_a(siguiente_escena)
	else:
		print("¡NIVEL COMPLETADO!")
		TransitionManager.viajar_a("res://Levels/Lobby.tscn")

extends Node

var habitacion_actual: int = 0
var ruta_generada: Array[String] = []

func iniciar_nivel(config: LevelConfig):
	habitacion_actual = 0
	ruta_generada.clear()
	
	# 1. Armamos el mazo temporal y lo mezclamos
	var temp_pool = config.pool_habitaciones.duplicate()
	temp_pool.shuffle()
	
	# 2. Elegimos las salas normales usando la cantidad de la configuración
	for i in range(config.cantidad_salas):
		ruta_generada.append(temp_pool[i % temp_pool.size()])
		
	# 3. Ponemos la Sala Final: Jefe
	ruta_generada.append(config.jefe_final)
	
	# 4. ¡Arrancamos el viaje!
	print("Nivel generado: ", config.nombre_nivel, " - Ruta: ", ruta_generada)
	avanzar_habitacion()

func avanzar_habitacion():
	if habitacion_actual < ruta_generada.size():
		var siguiente_escena = ruta_generada[habitacion_actual]
		habitacion_actual += 1
		TransitionManager.viajar_a(siguiente_escena)
	else:
		print("¡NIVEL COMPLETADO!")
		GameManager.vida_persistente = -1
		GameManager.escudo_persistente = 0
		TransitionManager.viajar_a("res://Levels/Lobby.tscn")

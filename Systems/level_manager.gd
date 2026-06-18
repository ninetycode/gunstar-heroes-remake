extends Node

var habitacion_actual: int = 0
var ruta_generada: Array[String] = []

# Guardamos los datos de la partida actual
var indice_nivel_actual: int = 0
var config_actual: LevelConfig = null

func iniciar_nivel(config: LevelConfig, indice: int):
	config_actual = config
	indice_nivel_actual = indice
	habitacion_actual = 0
	ruta_generada.clear()
	
	var temp_pool = config.pool_habitaciones.duplicate()
	temp_pool.shuffle()
	
	for i in range(config.cantidad_salas):
		ruta_generada.append(temp_pool[i % temp_pool.size()])
		
	ruta_generada.append(config.jefe_final)
	
	print("Iniciando: ", config.nombre_nivel)
	avanzar_habitacion()

func avanzar_habitacion():
	if habitacion_actual < ruta_generada.size():
		var siguiente_escena = ruta_generada[habitacion_actual]
		habitacion_actual += 1
		TransitionManager.viajar_a(siguiente_escena)
	else:
		print("¡NIVEL COMPLETADO!")
		
		# 1. Limpiamos las variables temporales de la partida
		GameManager.vida_persistente = -1
		GameManager.escudo_persistente = 0
		
		# 2. Desbloqueamos el siguiente nivel (si corresponde)
		if GameManager.nivel_maximo_alcanzado <= indice_nivel_actual:
			GameManager.nivel_maximo_alcanzado = indice_nivel_actual + 1
			
		# 3. ¿A dónde vamos ahora?
		if config_actual.es_nivel_final:
			# Cambiá esta ruta por la de tus créditos reales
			TransitionManager.viajar_a("res://UI/creditos.tscn") 
		else:
			TransitionManager.viajar_a("res://Levels/Lobby.tscn")

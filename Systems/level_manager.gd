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
	
	# === AUTOMATIZACIÓN DE MÚSICA DE ENTRADA ===
	if config.musica_ambiente != "":
		# Llama al AudioManager con un fundido de 1.5 segundos
		AudioManager.play_music(config.musica_ambiente, 0.0, 1.5)
	
	print("Iniciando: ", config.nombre_nivel)
	avanzar_habitacion()

func avanzar_habitacion():
	if habitacion_actual < ruta_generada.size():
		var siguiente_escena = ruta_generada[habitacion_actual]
		habitacion_actual += 1
		TransitionManager.viajar_a(siguiente_escena)
	else:
		print("¡NIVEL COMPLETADO!")
		
		# === FIX DE AUDIO LOBBY/CRÉDITOS AAA ===
		# Frenamos cualquier música que esté sonando (horda o jefe) con un fundido suave
		if has_node("/root/AudioManager"):
			AudioManager.stop_music(1.5)
		
		# 1. Limpiamos las variables temporales de la partida
		GameManager.vida_persistente = -1
		GameManager.escudo_persistente = 0
		
		# 2. Desbloqueamos el siguiente nivel (si corresponde)
		if GameManager.nivel_maximo_alcanzado <= indice_nivel_actual:
			GameManager.nivel_maximo_alcanzado = indice_nivel_actual + 1
			
		# 3. ¿A dónde vamos ahora?
		if config_actual == null:
			print("AVISO: config_actual es Nil (Prueba con F6). Mandando a créditos por seguridad.")
			TransitionManager.viajar_a("res://Scenes/creditosfinales.tscn")
		elif config_actual.es_nivel_final:
			TransitionManager.viajar_a("res://Scenes/creditosfinales.tscn") 
		else:
			TransitionManager.viajar_a("res://Levels/Lobby.tscn")

extends Node

var habitacion_actual: int = 0
var ruta_generada: Array[String] = []

# Guardamos los datos de la partida actual
var indice_nivel_actual: int = 0
var config_actual: LevelConfig = null
var cambiando_escena: bool = false

func iniciar_nivel(config: LevelConfig, indice: int):
	cambiando_escena = false
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
	print("Ruta exacta generada para este nivel: ", ruta_generada)
	avanzar_habitacion()

func avanzar_habitacion():
	# === CERROJO DE SEGURIDAD ANTIFANTASMA ===
	if cambiando_escena:
		return
		
	if habitacion_actual < ruta_generada.size():
		cambiando_escena = true
		var siguiente_escena = ruta_generada[habitacion_actual]
		habitacion_actual += 1
		
		TransitionManager.viajar_a(siguiente_escena)
		get_tree().create_timer(0.5).timeout.connect(func(): cambiando_escena = false)
		
	else:
		print("¡NIVEL COMPLETADO!")
		cambiando_escena = true
		
		# === ACÁ ESTÁ EL FIX: APAGAMOS LA MÚSICA DEL BOSS ===
		if has_node("/root/AudioManager"):
			# Le ponemos 0.0 para que corte en seco antes de la carga del Lobby
			AudioManager.stop_music(0.0) 
		
		GameManager.vida_persistente = -1
		GameManager.escudo_persistente = 0
		
		if GameManager.nivel_maximo_alcanzado <= indice_nivel_actual:
			GameManager.nivel_maximo_alcanzado = indice_nivel_actual + 1
			
		if config_actual == null:
			TransitionManager.viajar_a("res://Scenes/creditosfinales.tscn")
		elif config_actual.es_nivel_final:
			TransitionManager.viajar_a("res://Scenes/creditosfinales.tscn") 
		else:
			TransitionManager.viajar_a("res://Levels/Lobby.tscn")

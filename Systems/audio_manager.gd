extends Node

# Acá registramos todos los sonidos del juego con un nombre clave.
var sonidos: Dictionary = {
	#"disparo_laser": preload("res://Assets/Audio/SFX/laser_shoot.wav"),
	#"disparo_fuego": preload("res://Assets/Audio/SFX/flame_shoot.wav"),
	#"salto": preload("res://Assets/Audio/SFX/jump.wav"),
	#"explosion": preload("res://Assets/Audio/SFX/explosion.wav"),
	#"hit": preload("res://Assets/Audio/SFX/hit.wav")
}

# Pool de reproductores (nuestra "orquesta")
var reproductores: Array[AudioStreamPlayer] = []
var cantidad_reproductores: int = 12 # Cuántos sonidos pueden sonar exactamente al mismo tiempo
var indice_actual: int = 0

func _ready():
	# Al iniciar el juego, instanciamos los reproductores invisibles
	for i in range(cantidad_reproductores):
		var reproductor = AudioStreamPlayer.new()
		add_child(reproductor)
		reproductores.append(reproductor)

# Función universal que cualquier script puede llamar
func play_sfx(nombre_sonido: String, volumen_db: float = 0.0, pitch: float = 1.0):
	if not sonidos.has(nombre_sonido):
		print("ERROR: El sonido '", nombre_sonido, "' no existe en el AudioManager.")
		return
		
	# Agarramos el reproductor que toca en la lista
	var reproductor = reproductores[indice_actual]
	
	# Le pasamos los datos y le damos play
	reproductor.stream = sonidos[nombre_sonido]
	reproductor.volume_db = volumen_db
	reproductor.pitch_scale = pitch
	reproductor.play()
	
	# Avanzamos al siguiente. Si llegamos al 12, volvemos al 0.
	indice_actual = (indice_actual + 1) % cantidad_reproductores

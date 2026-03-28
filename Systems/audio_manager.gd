extends Node

# Acá registramos todos los sonidos del juego con un nombre clave.
# En el diccionario de sonidos o uno nuevo
var musicas: Dictionary = {
	#"nivel_1": preload("res://Assets/Audio/Music/stage_1_theme.ogg"),
	#"boss_theme": preload("res://Assets/Audio/Music/boss_battle.ogg")
}

var music_player: AudioStreamPlayer # El reproductor exclusivo de música

var sonidos: Dictionary = {
	"jump": preload("res://Assets/Audio/SFX/action_jump.mp3"),
	"change_weapon": preload("res://Assets/Audio/SFX/SCIMisc_Throw_Grenade_02.wav"),
	"disparo_laser": preload("res://Assets/Audio/SFX/LASRGun_Blaster_Single_Shot_02.wav"),
	"disparo_verde" : preload("res://Assets/Audio/SFX/Earth_Shooting_NoReverb_03.wav"),
	"disparo_fuego" : preload("res://Assets/Audio/SFX/Fire_Hit_01.wav"),
	"disparo_force" : preload("res://Assets/Audio/SFX/Earth_Shooting_NoReverb_02.wav")
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
	# 1. Creamos el pool de SFX (Los 12 canales)
	for i in range(cantidad_reproductores):
		var reproductor = AudioStreamPlayer.new()
		reproductor.bus = "SFX"
		add_child(reproductor)
		reproductores.append(reproductor)
	
	# 2. Creamos EL reproductor de música (UNO SOLO, afuera del bucle)
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music" 
	add_child(music_player)

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
	
# --- NUEVA FUNCIÓN PARA CORTAR SONIDOS ---
func stop_sfx(nombre_sonido: String):
	if not sonidos.has(nombre_sonido):
		return
		
	var audio_stream = sonidos[nombre_sonido]
	
	# Buscamos en nuestra "orquesta" quién está tocando este sonido y lo callamos
	for reproductor in reproductores:
		if reproductor.stream == audio_stream and reproductor.playing:
			reproductor.stop()
			
func play_music(nombre_track: String, volumen: float = 0.0):
	if not musicas.has(nombre_track):
		return
	
	# Si ya está sonando ese tema, no lo reinicies
	if music_player.stream == musicas[nombre_track] and music_player.playing:
		return
		
	music_player.stream = musicas[nombre_track]
	music_player.volume_db = volumen
	music_player.play()

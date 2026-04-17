extends Node

var _registro_tiempos: Dictionary = {}
var music_player: AudioStreamPlayer 
var reproductores: Array[AudioStreamPlayer] = []
var cantidad_reproductores: int = 12 # Cuántos sonidos pueden sonar exactamente al mismo tiempo
var indice_actual: int = 0

var musicas: Dictionary = {
	"nivel_1_zone_2": preload("res://Assets/Audio/SONGS/Doom (1993) OST — At Doom's Gate (Extended).mp3"),
	#"boss_theme": preload("res://Assets/Audio/Music/boss_battle.ogg")
	"nivel_1_zona1": preload("res://Assets/Audio/SONGS/Metal Slug X - Judgement (Mission 1) Cover.mp3")
}
 
var sonidos: Dictionary = {
	"jump": preload("res://Assets/Audio/SFX/action_jump.mp3"),
	"change_weapon": preload("res://Assets/Audio/SFX/SCIMisc_Throw_Grenade_02.wav"),
	"disparo_laser": preload("res://Assets/Audio/SFX/LASRGun_Blaster_Single_Shot_02.wav"),
	"disparo_verde" : preload("res://Assets/Audio/SFX/Earth_Shooting_NoReverb_03.wav"),
	"disparo_fuego" : preload("res://Assets/Audio/SFX/Fire_Hit_01.wav"),
	"disparo_force" : preload("res://Assets/Audio/SFX/Earth_Shooting_NoReverb_02.wav"),
	"soldier_death1": preload("res://Assets/Audio/SFX/metal-slug-fire-scream.mp3"),
	"soldier_death2" : preload("res://Assets/Audio/SFX/metal-slug-scream.wav"),
	"curacion" : preload("res://Assets/Audio/SFX/Positive_Pop_06.wav"),
	"laser_fly_enemy" : preload("res://Assets/Audio/SFX/LASRGun_Laser_Gun_Single_Shot_04.wav"),
	"game_over_sound" : preload("res://Assets/Audio/SFX/Jingle_Retro8bit_Chiptune_Melodic_Volume_1_4_1.wav")
	#"salto": preload("res://Assets/Audio/SFX/jump.wav"),
	#"explosion": preload("res://Assets/Audio/SFX/explosion.wav"),
	#"hit": preload("res://Assets/Audio/SFX/hit.wav")
	}


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
		print("ERROR: El sonido '", nombre_sonido, "' no existe.")
		return
		
	# --- ESCUDO ANTI-SATURACIÓN (THROTTLING) ---
	var ahora = Time.get_ticks_msec()
	
	if _registro_tiempos.has(nombre_sonido):
		# Si pasaron menos de 50 milisegundos desde que sonó ESTE mismo sonido, lo ignoramos
		if ahora - _registro_tiempos[nombre_sonido] < 50:
			return 
			
	# Actualizamos el registro con el tiempo actual
	_registro_tiempos[nombre_sonido] = ahora
	
	# ... (El resto de tu código queda igual) ...
	var reproductor = reproductores[indice_actual]
	reproductor.stream = sonidos[nombre_sonido]
	reproductor.volume_db = volumen_db
	reproductor.pitch_scale = pitch
	reproductor.play()
	
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
	
func stop_music(fade_out_duration: float = 1.0):
	# Si no hay música sonando, no hacemos nada
	if not music_player.playing:
		return
		
	# Si nos piden que se corte de golpe (tiempo 0)
	if fade_out_duration <= 0.0:
		music_player.stop()
		return
		
	# Creamos un Tween para bajar el volumen de a poco
	var tween = create_tween()
	# Le decimos que baje el volume_db a -80 (que es silencio total en Godot) en X segundos
	tween.tween_property(music_player, "volume_db", -80.0, fade_out_duration)
	
	# Cuando el tween termina de bajar el volumen, frenamos el reproductor y restauramos el volumen base
	await tween.finished
	music_player.stop()
	music_player.volume_db = 0.0 # Lo dejamos listo para la próxima canción

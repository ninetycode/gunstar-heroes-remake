extends Node

var _registro_tiempos: Dictionary = {}
var music_player: AudioStreamPlayer 
var reproductores: Array[AudioStreamPlayer] = []
var cantidad_reproductores: int = 12 # Cuántos sonidos pueden sonar exactamente al mismo tiempo
var indice_actual: int = 0
var _music_tween: Tween


var musicas: Dictionary = {
	"nivel_1_music": preload("res://Assets/Audio/SONGS/Doom (1993) OST — At Doom's Gate (Extended).mp3"),
	"boss_1" : preload("res://Assets/Audio/SONGS/Action Beat #4 (looped).wav"),
	#"boss_theme": preload("res://Assets/Audio/Music/boss_battle.ogg")
	"nivel_2_music": preload("res://Assets/Audio/SONGS/Metal Slug X - Judgement (Mission 1) Cover.mp3"),
	"boss_2" : preload("res://Assets/Audio/SONGS/Action Beat - Rock Version #3 (looped).wav"),
	"end" : preload("res://Assets/Audio/SONGS/Electronica - Theme 1 (looped).wav")
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
	"game_over_sound" : preload("res://Assets/Audio/SFX/Jingle_Retro8bit_Chiptune_Melodic_Volume_1_4_1.wav"),
	"estiramiento_papaya" : preload("res://Assets/Audio/SFX/Magical_Bow_PullBack_01.wav"),
	"ui_accept" : preload ("res://Assets/Audio/SFX/UI_Menu_ExpandOpen_Volume_1_3_2.wav"),
	"ui_cancel" : preload ("res://Assets/Audio/SFX/UI_ErrorAlert_Buzz_Volume_1_1_1.wav"),
	"cargando" : preload ("res://Assets/Audio/SFX/UI_LoadingProgress_SoftPulsate_Volume_1_4_1.wav"),
	"ui_move" : preload ("res://Assets/Audio/SFX/UI_HoverSelect_LightClick_Volume_1_8_1.wav"),
	"coin" : preload ("res://Assets/Audio/SFX/Collective_Coins_02.wav"),
	"boss2_jump" : preload("res://Assets/Audio/SFX/NaturalElements_ShortAirBursts_AirWhoosh_Volume_1_1_1.wav"),
	"boss2_attack" : preload("res://Assets/Audio/SFX/NaturalElements_ShortAirBursts_AirWhoosh_Volume_1_1_2.wav"),
	#"salto": preload("res://Assets/Audio/SFX/jump.wav"),
	#"explosion": preload("res://Assets/Audio/SFX/explosion.wav"),
	"hit": preload("res://Assets/Audio/SFX/CinematicHitsImpacts_QuickStings_AirWoosh_Fast_Volume_1_8_2.wav")
	}


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
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
			
func play_music(nombre_track: String, volumen_destino: float = 0.0, fade_in_duration: float = 1.0):
	if not musicas.has(nombre_track):
		return
	
	if music_player.stream == musicas[nombre_track] and music_player.playing:
		return
		
	# === ACCIÓN PREVENTIVA AAA ===
	# Si había un fade out corriendo (de la horda anterior), lo fulminamos 
	# para que no nos apague la música nueva al terminar.
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
		
	music_player.stream = musicas[nombre_track]
	
	if fade_in_duration > 0.0:
		music_player.volume_db = -80.0
		music_player.play()
		_music_tween = create_tween()
		_music_tween.tween_property(music_player, "volume_db", volumen_destino, fade_in_duration)
	else:
		music_player.volume_db = volumen_destino
		music_player.play()
	
func stop_music(fade_out_duration: float = 1.0):
	if not music_player.playing:
		return
		
	# Si ya había un tween corriendo, lo limpiamos antes de empezar uno nuevo
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
		
	if fade_out_duration <= 0.0:
		music_player.stop()
		return
		
	_music_tween = create_tween()
	_music_tween.tween_property(music_player, "volume_db", -80.0, fade_out_duration)
	
	# Usamos un método limpio de Tween en lugar de un await directo en el vacío
	_music_tween.tween_callback(func():
		music_player.stop()
		music_player.volume_db = 0.0
	)

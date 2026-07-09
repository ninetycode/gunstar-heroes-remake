extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var blue_anim = $Control/AnimatedSprite2D

var ruta_escena_destino: String = ""
var cargando: bool = false
var tiempo_minimo: float = 1.5 # 1.5 segundos de pantalla negra obligatorios
var tiempo_transcurrido: float = 0.0

func _ready():
	# === CRÍTICO: PANTALLA DE CARGA INMUNE A LA PAUSA ===
	# Le decimos a Godot que este CanvasLayer siga procesando sus animaciones 
	# y su lógica interna aunque congelemos el resto del universo de fondo.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	color_rect.material.set_shader_parameter("factor", 0.0)
	color_rect.hide()
	$Control.hide()

func viajar_a(ruta_escena: String):
	AudioManager.play_sfx("cargando")
	ruta_escena_destino = ruta_escena
	tiempo_transcurrido = 0.0
	cargando = true
	
	# === PASO 1: CONGELAR EL MUNDO DE FONDO ===
	# Frenamos físicas, inputs del jugador y lógica de enemigos al instante
	get_tree().paused = true
	
	color_rect.show()
	$Control.show()
	blue_anim.play("chargerun")
	
	ResourceLoader.load_threaded_request(ruta_escena_destino)
	
	var tween = create_tween()
	tween.tween_method(_actualizar_shader, 0.0, 1.0, 0.5)

func _actualizar_shader(valor: float):
	color_rect.material.set_shader_parameter("factor", valor)

func _process(delta):
	if not cargando:
		return
		
	tiempo_transcurrido += delta
	var estado_carga = ResourceLoader.load_threaded_get_status(ruta_escena_destino)
	
	if estado_carga == ResourceLoader.THREAD_LOAD_LOADED and tiempo_transcurrido >= tiempo_minimo:
		cargando = false
		_terminar_transicion()
	
	elif estado_carga == ResourceLoader.THREAD_LOAD_FAILED:
		print("Error: No se pudo cargar la escena: ", ruta_escena_destino)
		# Si la carga falla por un error de ruta, despausamos por seguridad para no romper el motor
		get_tree().paused = false
		cargando = false

func _terminar_transicion():
	var escena_empaquetada = ResourceLoader.load_threaded_get(ruta_escena_destino)
	get_tree().change_scene_to_packed(escena_empaquetada)
	
	blue_anim.stop()
	$Control.hide()
	
	# === PASO 2: QUITAR EL FRENO DE MANO ===
	# Una vez que la pantalla destino ya se montó en el motor, devolvemos el juego a la vida
	get_tree().paused = false
	
	var tween = create_tween()
	tween.tween_method(_actualizar_shader, 1.0, 0.0, 0.5)
	tween.tween_callback(color_rect.hide)

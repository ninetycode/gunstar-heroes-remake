extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var blue_anim = $Control/AnimatedSprite2D

var ruta_escena_destino: String = ""
var cargando: bool = false
var tiempo_minimo: float = 1.5 # 1.5 segundos de pantalla negra obligatorios
var tiempo_transcurrido: float = 0.0

func _ready():
	# Arrancamos con la pantalla transparente y Blue invisible
	
	color_rect.material.set_shader_parameter("factor", 0.0)
	color_rect.hide()
	$Control.hide()

func viajar_a(ruta_escena: String):
	AudioManager.play_sfx("cargando")
	ruta_escena_destino = ruta_escena
	tiempo_transcurrido = 0.0
	cargando = true
	
	# 1. Hacemos visibles los elementos
	color_rect.show()
	$Control.show()
	blue_anim.play("chargerun") # [Inferencia] Asumo que tu animación de correr se llama así
	
	# 2. Le decimos a Godot que empiece a cargar el nivel en segundo plano
	ResourceLoader.load_threaded_request(ruta_escena_destino)
	
	# 3. Animamos el Shader para que cierre la pantalla
	var tween = create_tween()
	tween.tween_method(_actualizar_shader, 0.0, 1.0, 0.5)

# Función para actualizar el parámetro 'factor' del shader
func _actualizar_shader(valor: float):
	color_rect.material.set_shader_parameter("factor", valor)

func _process(delta):
	if not cargando:
		return
		
	tiempo_transcurrido += delta
	
	# Chequeamos cómo va la carga en segundo plano
	var estado_carga = ResourceLoader.load_threaded_get_status(ruta_escena_destino)
	
	# Si ya terminó de cargar Y además pasamos el tiempo mínimo que queríamos
	if estado_carga == ResourceLoader.THREAD_LOAD_LOADED and tiempo_transcurrido >= tiempo_minimo:
		cargando = false
		_terminar_transicion()
	
	elif estado_carga == ResourceLoader.THREAD_LOAD_FAILED:
		print("Error: No se pudo cargar la escena: ", ruta_escena_destino)
		cargando = false

func _terminar_transicion():
	# 1. Obtenemos la escena ya armada desde la memoria
	var escena_empaquetada = ResourceLoader.load_threaded_get(ruta_escena_destino)
	
	# 2. Hacemos el cambio oficial (es instantáneo porque ya está cargada)
	get_tree().change_scene_to_packed(escena_empaquetada)
	
	# 3. Paramos a Blue
	blue_anim.stop()
	$Control.hide()
	
	# 4. Abrimos la pantalla usando el shader nuevamente
	var tween = create_tween()
	tween.tween_method(_actualizar_shader, 1.0, 0.0, 0.5)
	
	# 5. Ocultamos todo al final
	tween.tween_callback(color_rect.hide)

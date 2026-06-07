extends Camera2D

var player 
var bloqueada = false 
var es_sala_jefe = false

@export var altura_fija_y: float = 240.0 

func _ready():
	player = get_tree().current_scene.find_child("GunstarBlue", true, false)
	# Habilitamos el suavizado pero con una velocidad que se sienta "rápida"
	position_smoothing_enabled = true
	position_smoothing_speed = 7.0 
	anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER

func _process(_delta):
	# Forzamos Y constante
	global_position.y = altura_fija_y
	
	if player == null: return
	
	if not bloqueada:
		# Lógica de seguimiento: Solo movemos X si el jugador está a la derecha del centro actual
		if player.global_position.x > global_position.x:
			global_position.x = player.global_position.x
	# Si está bloqueada, no hacemos nada en _process, dejamos que el Tween tome el control

func bloquear_en_posicion(posicion_x_arena: float, es_jefe: bool):
	bloqueada = true
	es_sala_jefe = es_jefe
	
	# Tween para centrar la cámara en la sala
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Usamos un tiempo corto (0.3s) para que no se sienta lento, pero sí suave
	tween.tween_property(self, "global_position:x", posicion_x_arena, 0.3)

func permitir_avance():
	if not es_sala_jefe:
		bloqueada = false

extends Camera2D

var player 
var bloqueada = false 
var es_sala_jefe = false # NUEVA VARIABLE

@export var altura_fija_y: float = 240.0 

func _ready():
	player = get_tree().current_scene.find_child("GunstarBlue", true, false)
	global_position.y = altura_fija_y
	position_smoothing_enabled = true # ¡Fundamental para suavidad!
	position_smoothing_speed = 3.0   # Ajusta esto (menor = más suave/lento)

func _process(_delta):
	global_position.y = altura_fija_y
	if player == null or bloqueada: return
	
	# Seguimiento horizontal fluido
	if player.global_position.x > global_position.x:
		global_position.x = player.global_position.x

func bloquear_en_posicion(posicion_x_arena: float, es_jefe: bool):
	bloqueada = true
	es_sala_jefe = es_jefe # Marcamos si es jefe o horda
	
	# Usamos un tween para deslizar la cámara al centro de la sala suavemente
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:x", posicion_x_arena, 0.5)

func permitir_avance():
	# Si es jefe, ignoramos esta orden
	if es_sala_jefe: 
		return
	bloqueada = false

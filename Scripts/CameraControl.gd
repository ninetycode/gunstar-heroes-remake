extends Camera2D

var player 
var bloqueada = false 
var seguimiento_horizontal = true 

@export var altura_fija_y: float = 240.0 

func _ready():
	# Buscamos al jugador por grupo o unique_id
	player = get_tree().get_first_node_in_group("Player")
	position_smoothing_enabled = true # ¡Muy importante para suavidad!
	position_smoothing_speed = 5.0

func _process(_delta):
	global_position.y = altura_fija_y

	if player == null or bloqueada: 
		return
	
	if seguimiento_horizontal and player.global_position.x > global_position.x:
		global_position.x = player.global_position.x

# Llamado por el AreaManager al entrar
func bloquear_en_posicion(posicion_x_arena: float):
	bloqueada = true
	seguimiento_horizontal = false
	
	# Tween para deslizarse suavemente al centro de la arena
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:x", posicion_x_arena, 0.8)

# Llamado por el AreaManager al completar la sala
func permitir_avance():
	bloqueada = false
	
	# Esperamos un momento a que el jugador se aleje un poco si es necesario
	# o simplemente reactivamos el seguimiento suave
	await get_tree().create_timer(0.5).timeout
	seguimiento_horizontal = true

extends Camera2D

@export var player_path: NodePath
@onready var player = get_node(player_path)

var bloqueada = false
var limite_izquierdo_pantalla = 0.0

func _process(_delta):
	if player == null: return
	
	# Solo seguimos al jugador si no está bloqueada y si el jugador va hacia la derecha
	if not bloqueada:
		if player.global_position.x > global_position.x:
			global_position.x = player.global_position.x
	
	# Impedir que el jugador retroceda fuera de la vista de la cámara
	# (Común en juegos de scroll lateral)
	limite_izquierdo_pantalla = global_position.x - (get_viewport_rect().size.x / 2) / zoom.x
	if player.global_position.x < limite_izquierdo_pantalla:
		player.global_position.x = limite_izquierdo_pantalla

func bloquear_camara():
	bloqueada = true

func desbloquear_camara():
	bloqueada = false

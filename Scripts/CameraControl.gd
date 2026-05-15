# CameraControl.gd
extends Camera2D

var player 
var bloqueada = false # Empezamos bloqueada
var seguimiento_horizontal = false 

@export var limite_suelo_y: int = 368

func _ready():
	player = get_tree().current_scene.find_child("GunstarBlue", true, false)
	limit_bottom = limite_suelo_y

func _process(_delta):
	if player == null or bloqueada: 
		return
	
	# Seguimiento Horizontal (Solo si está activo)
	if seguimiento_horizontal and player.global_position.x > global_position.x:
		global_position.x = player.global_position.x

# Llamaremos a esto cuando termine la horda
func permitir_avance():
	bloqueada = false
	seguimiento_horizontal = true

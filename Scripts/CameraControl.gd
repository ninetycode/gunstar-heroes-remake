extends Camera2D

var player # Ya no usamos NodePath para evitar olvidos en el Inspector
var bloqueada = false

func _ready():
	# Buscamos a Blue automáticamente al arrancar
	player = get_tree().current_scene.find_child("GunstarBlue", true, false)

func _process(_delta):
	if player == null or bloqueada: 
		return
	
	# SOLO seguimos en X si el jugador se mueve a la derecha de la cámara
	if player.global_position.x > global_position.x:
		global_position.x = player.global_position.x
func bloquear_camara():
	bloqueada = true

func desbloquear_camara():
	bloqueada = false

extends Camera2D

var player 
var bloqueada = false
var seguimiento_vertical = false # Nuestro nuevo modo pirámide

func _ready():
	player = get_tree().current_scene.find_child("GunstarBlue", true, false)

func _process(_delta):
	if player == null or bloqueada: 
		return
	
	# 1. Movimiento Horizontal (Siempre activo hacia la derecha)
	if player.global_position.x > global_position.x:
		global_position.x = player.global_position.x
		
	# 2. Movimiento Vertical (Solo se activa en la pirámide)
	if seguimiento_vertical:
		# Hacemos que la cámara iguale la altura de Blue.
		# Como tu nodo Camera2D tiene "Position Smoothing" activado, 
		# este movimiento hacia arriba se va a ver súper fluido.
		global_position.y = player.global_position.y

func bloquear_camara():
	bloqueada = true

func desbloquear_camara():
	bloqueada = false

# --- NUEVAS FUNCIONES ---
func activar_diagonal():
	seguimiento_vertical = true

func desactivar_diagonal():
	seguimiento_vertical = false

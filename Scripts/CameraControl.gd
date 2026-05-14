extends Camera2D

var player 
var bloqueada = false

# Ajustá este valor en el Inspector hasta que lo gris desaparezca.
# Es la coordenada Y "máxima" que la cámara puede mostrar.
@export var limite_suelo_y: int = 368

func _ready():
	player = get_tree().current_scene.find_child("GunstarBlue", true, false)
	# Inicialmente, ponemos el límite para que no se vea el fondo gris desde el segundo 1
	limit_bottom = limite_suelo_y

func _process(_delta):
	if player == null or bloqueada: 
		return
	
	# 1. Seguimiento Horizontal
	if player.global_position.x > global_position.x:
		global_position.x = player.global_position.x
		
	

func bloquear_camara():
	bloqueada = true

func desbloquear_camara():
	bloqueada = false

extends Camera2D

var player 
var bloqueada = false
var seguimiento_vertical = false 

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
		
	# 2. Seguimiento Vertical (Diagonal)
	if seguimiento_vertical:
		# Al seguir a Blue en Y, limit_bottom impedirá automáticamente 
		# que la cámara baje de la cuenta.
		global_position.y = player.global_position.y

func bloquear_camara():
	bloqueada = true

func desbloquear_camara():
	bloqueada = false

func activar_diagonal():
	seguimiento_vertical = true

func desactivar_diagonal():
	seguimiento_vertical = false

extends Camera2D

var player 
var bloqueada = false 
var seguimiento_horizontal = true 

@export var limite_suelo_y: int = 368

## NUEVO: Ajusta la altura fija de la cámara en el eje Y.
## Cuanto más alto sea este número, más BAJO se posicionará la cámara (mostrará más suelo).
@export var altura_fija_y: float = 240.0 

func _ready():
	player = get_tree().current_scene.find_child("GunstarBlue", true, false)
	limit_bottom = limite_suelo_y
	
	# Forzamos la altura inicial en Y al comenzar
	global_position.y = altura_fija_y

func _process(_delta):
	# Mantenemos la cámara siempre en la altura deseada en Y
	global_position.y = altura_fija_y

	if player == null or bloqueada: 
		return
	
	# Seguimiento clásico hacia la derecha
	if seguimiento_horizontal and player.global_position.x > global_position.x:
		global_position.x = player.global_position.x

# Llamado por el AreaManager de la sala actual al iniciar el combate
func bloquear_en_posicion(posicion_x_arena: float):
	bloqueada = true
	seguimiento_horizontal = false
	global_position.x = posicion_x_arena 

# Llamado por el AreaManager al limpiar la oleada de enemigos
func permitir_avance():
	bloqueada = false
	seguimiento_horizontal = true

extends Area2D

# Variables base que la bala va a usar en vuelo
var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT

@onready var sprite = $Sprite2D

func _ready():
	# 1. Conectamos la señal de salir de pantalla
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	
	# 2. Conectamos la señal de chocar contra una pared/piso
#	body_entered.connect(_on_body_entered)
	
	# 3. Apenas nace en el cargador oculto del nivel, se apaga sola
	desactivar()

func _physics_process(delta):
	position += direction * speed * delta

# --- FUNCIONES DEL POOLING ---

# Esta función la va a llamar el BulletPool cuando apretes el gatillo
func activar(pos: Vector2, dir: Vector2, nueva_velocidad: float, nueva_textura: Texture2D):
	global_position = pos
	direction = dir
	rotation = dir.angle()
	speed = nueva_velocidad
	
	# Si el arma le pasa una textura nueva (ej: fuego o láser), se la cambiamos
	if sprite and nueva_textura:
		sprite.texture = nueva_textura
		
	# La prendemos
	visible = true
	set_physics_process(true)
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)

# Esta función la apaga para reciclarla
func desactivar():
	visible = false
	set_physics_process(false)
	# Apagamos las colisiones para que no haga daño estando invisible
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

# --- SEÑALES ---

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Salió de la pantalla: la reciclamos
	desactivar()

func _on_body_entered(_body):
	# Chocó contra una pared o el piso: la reciclamos. 
	# (Asegurate en el editor que la Mask de esta Area2D solo choque con el mundo/enemigos, no con el jugador)
	desactivar()

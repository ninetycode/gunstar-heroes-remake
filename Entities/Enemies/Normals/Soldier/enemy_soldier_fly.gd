extends CharacterBody2D

enum States { AWAIT, FLYING }
var current_state = States.AWAIT

@onready var sprite = $AnimatedSprite2D
@onready var remote_transform = $AnimatedSprite2D/RemoteTransform2D
@onready var mochila = $EnemyFlyMachine # Asegurate que se llame así en el árbol

# Ajustes de posición para la mochila (Puntos de la espalda)
const OFFSET_AGACHADO = Vector2(0, 10)
const OFFSET_VOLANDO = Vector2(-3, -8)

func _ready():
	current_state = States.AWAIT
	sprite.play("agachado")
	actualizar_posicion_mochila()
	# Que no haga nada hasta que la cinemática le avise
	set_physics_process(false) 

func actualizar_posicion_mochila():
	if sprite.animation == "agachado":
		remote_transform.position = OFFSET_AGACHADO
	else:
		remote_transform.position = OFFSET_VOLANDO

func despegar():
	current_state = States.FLYING
	sprite.play("volando")
	actualizar_posicion_mochila()
	set_physics_process(true) # Activamos el movimiento

func _physics_process(delta):
	if current_state == States.FLYING:
		# "Derechito por Y y que no rompa las bolas"
		velocity.y = -250 # Velocidad hacia arriba
		velocity.x = 0
		move_and_slide()
		
		# Si se sale de la pantalla por arriba, lo borramos para no gastar memoria
		if global_position.y < -100:
			queue_free()

extends CharacterBody2D

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn")

@export var speed = 300.0
@export var jump_velocity = -500.0
@export var gravity = 1200.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var muzzle = $AnimatedSprite2D/muzzle
@onready var shooter_time = $ShooterTime

func _physics_process(delta):
	# La gravedad se aplica siempre
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Movemos al personaje según lo que digan los estados
	move_and_slide()

# Le pasamos el Vector2 que nos calcula el WeaponComponent
func actualizar_animacion_apuntado(dir: Vector2):
	# Si no tocamos ninguna flecha, miramos al frente
	if dir == Vector2.ZERO:
		_animated_sprite.play("Disparo recto")
		return
		
	# Si tocamos izquierda o derecha, espejamos el sprite
	if dir.x != 0:
		_animated_sprite.flip_h = dir.x < 0

	# Lógica vertical y diagonal
	if dir.y < 0: # Apuntando hacia arriba
		if dir.x != 0:
			_animated_sprite.play("Disparo diagonal arriba")
		else:
			_animated_sprite.play("Disparo arriba")
			
	elif dir.y > 0: # Apuntando hacia abajo
		if is_on_floor():
			_animated_sprite.play("Crouch") # Se agacha si está en el piso
		else:
			_animated_sprite.play("Disparo abajo") # Dispara para abajo en el aire
			
	else: # Apuntando puramente a los costados
		_animated_sprite.play("Disparo recto")

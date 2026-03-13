extends CharacterBody2D

# --- CONFIGURACIÓN DE ESCENAS Y NODOS ---
const BULLET_SCENE = preload("res://Bullet.tscn") # Asegurate que la ruta sea esta

@onready var speed = 300.0
@onready var jump_velocity = -500.0
@onready var gravity = 1200.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var muzzle = $AnimatedSprite2D/muzzle
@onready var shooter_time = $ShooterTime # Referencia limpia al Timer

# --- VARIABLES DE JUEGO ---
var slot_1 = "FORCE"
var slot_2 = ""

func _physics_process(delta):
	# 1. Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Lógica de Estados (Movimiento y Animaciones)
	_handle_state_logic()
	
	# 4. Aplicar Movimiento
	move_and_slide()

	# 5. Disparo (Ráfaga)
	if Input.is_action_pressed("disparo") and shooter_time.is_stopped():
		shoot()
		shooter_time.start()

func _handle_state_logic():
	var is_aiming = Input.is_action_pressed("disparo")
	var input_v = Input.get_axis("ui_up", "ui_down")
	var input_h = Input.get_axis("ui_left", "ui_right")

	if is_aiming:
		# MODO FIXED: No se mueve mientras apunta
		velocity.x = 0
		_play_aim_animation(input_h, input_v)
	else:
		# MODO MOVIMIENTO: Caminar normal
		if input_h:
			velocity.x = input_h * speed
			_animated_sprite.flip_h = input_h < 0
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		_play_move_animation(input_h)

func _play_aim_animation(h, v):
	# El flip depende de qué tecla horizontal toques mientras apuntas
	if h != 0:
		_animated_sprite.flip_h = h < 0

	# Prioridad de poses de disparo
	if v < 0:
		_animated_sprite.play("Disparo arriba")
	elif v > 0:
		if is_on_floor():
			_animated_sprite.play("Crouch") # O "Chourch" si no lo corregiste
		else:
			_animated_sprite.play("Disparo abajo")
	else:
		_animated_sprite.play("Disparo recto")

func _play_move_animation(h):
	if not is_on_floor():
		_animated_sprite.play("Jump")
	elif h != 0:
		_animated_sprite.play("Run")
	else:
		_animated_sprite.play("Idle")

func shoot():
	var bullet = BULLET_SCENE.instantiate()
	
	# Configuración del tipo de bala (Force por defecto)
	if bullet.has_method("set_type"): # Por si querés usar una función en la bala
		bullet.set_type(slot_1)
	
	# Si tu bala usa las variables directamente:
	bullet.direction = _get_aim_direction()
	bullet.global_position = muzzle.global_position
	
	# Rotamos la bala para que apunte a donde viaja
	bullet.rotation = bullet.direction.angle()
	
	get_tree().root.add_child(bullet)
	
func _get_aim_direction() -> Vector2:
	var v = Input.get_axis("ui_up", "ui_down")
	var h = Input.get_axis("ui_left", "ui_right")
	var dir = Vector2(h, v)
	
	# Si no estás tocando ninguna dirección, dispara hacia donde mira el sprite
	if dir == Vector2.ZERO:
		return Vector2.LEFT if _animated_sprite.flip_h else Vector2.RIGHT
		
	# Si estás tocando algo, devolvemos la dirección normalizada
	return dir.normalized()

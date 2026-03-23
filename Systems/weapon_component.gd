extends Node

# Cargamos por defecto el arma de fuerza
@export var arma_actual: WeaponResource = preload("res://Resources/arma_laser.tres")

@onready var cooldown_timer = $CooldownTimer
@onready var player = owner

func _ready():
	# Ajustamos el tiempo del timer según el arma que tengamos
	if arma_actual:
		cooldown_timer.wait_time = arma_actual.fire_rate
		
		# ¡Le damos la orden al Pool de fabricar las 50 balas al iniciar!
		BulletPool.initialize_pool(arma_actual.bullet_scene, arma_actual.danio)

func disparar():
	if cooldown_timer.is_stopped() and arma_actual:
		var direccion = obtener_direccion_apuntado()
		
		# Le pasamos todos los datos del recurso al Pool
		BulletPool.disparar_bala(
			player.muzzle.global_position, 
			direccion, 
			arma_actual
		)
		
		cooldown_timer.start()

func obtener_direccion_apuntado() -> Vector2:
	# (Mantené tu lógica de las 8 direcciones que ya funciona joya )
	var v = Input.get_axis("ui_up", "ui_down")
	var h = Input.get_axis("ui_left", "ui_right")
	var dir = Vector2(h, v)
	if dir == Vector2.ZERO:
		return Vector2.LEFT if player._animated_sprite.flip_h else Vector2.RIGHT
	return dir.normalized()
	
func cambiar_arma(nuevo_recurso: WeaponResource):
	arma_actual = nuevo_recurso
	cooldown_timer.wait_time = arma_actual.fire_rate
	
	# Le avisamos al Pool que mate las balas viejas y cree 50 nuevas
	# de la nueva escena y con el nuevo daño.
	BulletPool.initialize_pool(arma_actual.bullet_scene, arma_actual.danio)

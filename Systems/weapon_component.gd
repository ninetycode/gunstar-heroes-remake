extends Node

# Cargamos por defecto el arma de fuerza
@export var arma_actual: WeaponResource = preload("res://Resources/arma_laser.tres")

@onready var cooldown_timer = $CooldownTimer
@onready var player = owner

func _ready():
	# Ajustamos el tiempo del timer según el arma que tengamos
	if arma_actual:
		cooldown_timer.wait_time = arma_actual.fire_rate
		# ¡Le damos la orden al Pool de fabricar las balas al iniciar!
		BulletPool.initialize_pool(arma_actual.bullet_scene, arma_actual.danio)

func disparar():
	if cooldown_timer.is_stopped() and arma_actual:
		var direccion = obtener_direccion_apuntado()
		
		# CAMBIO CLAVE: Usamos 'get_bullet' y pasamos 'false' al final (no es enemigo)
		# Esto evita el parpadeo rojo y permite que dañe a los robots
		BulletPool.get_bullet(
			player.muzzle.global_position, 
			direccion, 
			arma_actual,
			false # de_enemigo = false
		)
		
		cooldown_timer.start()

func obtener_direccion_apuntado() -> Vector2:
	var v = Input.get_axis("ui_up", "ui_down")
	var h = Input.get_axis("ui_left", "ui_right")
	var dir = Vector2(h, v)
	
	if dir == Vector2.ZERO:
		# Lógica de flip para cuando no tocás ninguna tecla
		return Vector2.LEFT if player._animated_sprite.flip_h else Vector2.RIGHT
	return dir.normalized()
	
func cambiar_arma(nuevo_recurso: WeaponResource):
	if nuevo_recurso == null: return
	
	arma_actual = nuevo_recurso
	cooldown_timer.wait_time = arma_actual.fire_rate
	
	# Reiniciamos el Pool con la nueva escena de bala (ej: lanzallamas o green bullet)
	BulletPool.initialize_pool(arma_actual.bullet_scene, arma_actual.danio)

extends Node

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn") 

@onready var cooldown_timer = $CooldownTimer
@onready var player = owner

# Agregamos un parámetro opcional 'direccion_externa'
func disparar(direccion_externa: Vector2 = Vector2.ZERO):
	if not cooldown_timer.is_stopped():
		return

	var bullet = BULLET_SCENE.instantiate()
	
	# Si el estado nos pasó una dirección, usamos esa. 
	# Si no (es ZERO), usamos la lógica automática.
	var direccion = direccion_externa
	if direccion == Vector2.ZERO:
		direccion = obtener_direccion_apuntado()
	
	# Posicionamiento nítido desde el muzzle
	bullet.global_position = player.muzzle.global_position 
	
	# Configuración de la bala
	bullet.direction = direccion
	bullet.rotation = direccion.angle()
	
	# Usar add_child en la escena actual es más seguro que en root
	get_tree().current_scene.add_child(bullet)
	cooldown_timer.start()

func obtener_direccion_apuntado() -> Vector2:
	var v = Input.get_axis("ui_up", "ui_down")
	var h = Input.get_axis("ui_left", "ui_right")
	var dir = Vector2(h, v)
	
	if dir == Vector2.ZERO:
		return Vector2.LEFT if player._animated_sprite.flip_h else Vector2.RIGHT
		
	return dir.normalized()

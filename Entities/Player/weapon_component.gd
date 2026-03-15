# weapon_component.gd
extends Node

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn") 

@onready var cooldown_timer = $CooldownTimer
@onready var player = owner

func disparar(direccion_fija: Vector2 = Vector2.ZERO):
	if not cooldown_timer.is_stopped():
		return

	# Si no nos pasan dirección, la calculamos
	var final_dir = direccion_fija
	if final_dir == Vector2.ZERO:
		final_dir = obtener_direccion_apuntado()

	var bullet = BULLET_SCENE.instantiate()
	
	# USAMOS EL NODO MUZZLE QUE VEO EN TU CAPTURA
	# Está adentro de AnimatedSprite2D
	bullet.global_position = player.get_node("AnimatedSprite2D/muzzle").global_position
	
	bullet.direction = final_dir
	bullet.rotation = final_dir.angle()
	
	get_tree().current_scene.add_child(bullet)
	cooldown_timer.start()

func obtener_direccion_apuntado() -> Vector2:
	var h = Input.get_axis("ui_left", "ui_right")
	var v = Input.get_axis("ui_up", "ui_down")
	
	if owner.is_on_floor() and v > 0: v = 0
	
	var dir = Vector2(h, v)
	
	if dir.length() < 0.1:
		return Vector2.LEFT if owner.get_node("AnimatedSprite2D").flip_h else Vector2.RIGHT
		
	return dir.normalized()

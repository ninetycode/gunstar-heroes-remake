# weapon_component.gd
extends Node

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn") 

@onready var cooldown_timer = $CooldownTimer
@onready var player = owner

func disparar():
	if cooldown_timer.is_stopped():
		var direccion = obtener_direccion_apuntado()
		
		# Le pasamos la pelota al Autoload
		BulletPool.disparar_bala(player.muzzle.global_position, direccion)
		
		cooldown_timer.start()

func obtener_direccion_apuntado() -> Vector2:
	var v = Input.get_axis("ui_up", "ui_down")
	var h = Input.get_axis("ui_left", "ui_right")
	var dir = Vector2(h, v)
	
	if dir == Vector2.ZERO:
		return Vector2.LEFT if player._animated_sprite.flip_h else Vector2.RIGHT
		
	return dir.normalized()

extends Node

# Chequeá que la ruta de tu bala sea exactamente esta
const BULLET_SCENE = preload("res://Scenes/Bullet.tscn") 

@onready var cooldown_timer = $CooldownTimer
@onready var player = owner

func disparar():
	# Si el temporizador terminó, podemos volver a disparar
	if cooldown_timer.is_stopped():
		var bullet = BULLET_SCENE.instantiate()
		var direccion = obtener_direccion_apuntado()
		
		# Ponemos la bala en el cañón (muzzle)
		bullet.global_position = player.muzzle.global_position 
		
		# Le pasamos la rotación y dirección
		bullet.direction = direccion
		bullet.rotation = direccion.angle()
		
		# Instanciamos la bala en el mundo, no adentro del jugador
		get_tree().root.add_child(bullet)
		cooldown_timer.start()

func obtener_direccion_apuntado() -> Vector2:
	var v = Input.get_axis("ui_up", "ui_down")
	var h = Input.get_axis("ui_left", "ui_right")
	var dir = Vector2(h, v)
	
	# Si no tocamos ninguna flecha, tira para el lado que mira el personaje
	if dir == Vector2.ZERO:
		return Vector2.LEFT if player._animated_sprite.flip_h else Vector2.RIGHT
		
	return dir.normalized()

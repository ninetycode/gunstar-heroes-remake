extends State

@onready var player = owner

func enter() -> void:
	# Al entrar, reproducimos la animación de correr
	player._animated_sprite.play("Run")

func physics_update(_delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Si nos estamos moviendo, aplicamos velocidad y giramos el sprite
	if direction != 0:
		player.velocity.x = direction * player.speed
		player._animated_sprite.flip_h = direction < 0
	else:
		# Si soltamos los botones, volvemos a Idle
		state_machine.transition_to("Idle")
		
	# Si apretamos saltar mientras corremos, pasamos a Jump
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.transition_to("Jump")
		
	# Si mantenemos apretado el botón, dispara
	if Input.is_action_pressed("disparo"):
		player.get_node("WeaponComponent").disparar()

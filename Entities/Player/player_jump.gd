extends State

@onready var player = owner

func enter(_msg := {}) -> void:
	player._animated_sprite.play("Jump")
	player.velocity.y = player.jump_velocity

func physics_update(_delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	player.velocity.x = direction * player.speed if direction != 0 else move_toward(player.velocity.x, 0, player.speed)
	if direction != 0: player._animated_sprite.flip_h = direction < 0

	# Si apretamos disparo (cualquiera), vamos al estado de disparo aéreo
	if Input.is_action_pressed("disparo"):
		state_machine.transition_to("JumpShotDown")
		return

	if player.velocity.y >= 0:
		state_machine.transition_to("Fall")
		return

	if player.is_on_floor():
		state_machine.transition_to("Idle")

	if Input.is_action_just_pressed("ui_up"): # Si el jugador intenta colgarse
		var ray = player.get_node("HangingRay")
		if ray.is_colliding():
			state_machine.transition_to("Hanging")

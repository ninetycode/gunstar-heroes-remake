extends State

@onready var player = owner

func enter(_msg := {}) -> void:
	if player._animated_sprite.animation != "Jump":
		player._animated_sprite.play("Jump")

func physics_update(_delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	player.velocity.x = direction * player.speed if direction != 0 else move_toward(player.velocity.x, 0, player.speed)
	if direction != 0: player._animated_sprite.flip_h = direction < 0

	if Input.is_action_pressed("disparo"):
		state_machine.transition_to("JumpShotDown")
		return

	if player.is_on_floor():
		state_machine.transition_to("Run" if direction != 0 else "Idle")

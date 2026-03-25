extends State

@onready var enemy = owner
var target_pos: Vector2
var change_timer = 0.0

func enter(_msg := {}) -> void:
	enemy.sprite.play("Fly") #

func physics_update(delta: float) -> void:
	change_timer -= delta
	if change_timer <= 0:
		# Elegimos un punto al azar alrededor de Blue
		var angle = randf() * TAU
		target_pos = enemy.player.global_position + Vector2(cos(angle), sin(angle)) * 250.0
		change_timer = randf_range(1.0, 2.5)

	# Movimiento hacia el target + Separación + Límites de cámara
	var dir = (target_pos - enemy.global_position).normalized()
	var separation = enemy.calcular_separacion()
	enemy.velocity = enemy.velocity.lerp(dir * enemy.velocidad + separation, delta * 2.0)
	
	enemy.limitar_a_camara() #
	enemy.move_and_slide()
	
	# Orientar sprite
	enemy.sprite.flip_h = (enemy.player.global_position.x - enemy.global_position.x) > 0

	# Transición: Si el timer de disparo del enemigo llega a cero
	if enemy.can_shoot:
		state_machine.transition_to("Attack")

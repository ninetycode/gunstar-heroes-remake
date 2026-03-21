extends State

@onready var enemy = owner 

func enter(_msg := {}) -> void:
	print("Soldado: Entrando a CHASE")

func physics_update(_delta: float) -> void:
	if not enemy.player: return
	
	var dir = (enemy.player.global_position - enemy.global_position).normalized()
	enemy.velocity.x = dir.x * enemy.speed
	
	enemy.sprite.flip_h = dir.x < 0
	
	# Solo le damos play si no lo estaba reproduciendo ya
	if enemy.sprite.animation != "walk":
		enemy.sprite.play("walk")
	
	var dist = enemy.global_position.distance_to(enemy.player.global_position)
	if dist < enemy.attack_range:
		state_machine.transition_to("Attack")
	elif dist > 350.0: # Si te alejás mucho, se aburre y vuelve a Idle
		state_machine.transition_to("Idle")

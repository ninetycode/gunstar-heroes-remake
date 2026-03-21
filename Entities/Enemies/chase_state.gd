extends State

@onready var enemy = owner 

func enter(_msg := {}) -> void:
	print("Soldado: Entrando a CHASE")

func physics_update(_delta: float) -> void:
	# Chequeamos si el jugador es una instancia válida en memoria.
	# Si lo mataron con queue_free(), esto da falso y lo pasamos a Idle.
	if not is_instance_valid(enemy.player):
		state_machine.transition_to("Idle")
		return
	
	var dir = (enemy.player.global_position - enemy.global_position).normalized()
	enemy.velocity.x = dir.x * enemy.speed
	
	enemy.sprite.flip_h = dir.x < 0
	
	if enemy.sprite.animation != "walk":
		enemy.sprite.play("walk")
	
	var dist = enemy.global_position.distance_to(enemy.player.global_position)
	if dist < enemy.attack_range:
		state_machine.transition_to("Attack")
	elif dist > 350.0: 
		state_machine.transition_to("Idle")

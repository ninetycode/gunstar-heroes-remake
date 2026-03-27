extends State

@onready var enemy = owner
@export var vision_range: float = 250.0 # Qué tan cerca tenés que estar para que te vea

func enter(_msg := {}) -> void:
	print("Soldado: Entrando a IDLE")
	enemy.velocity = Vector2.ZERO
	enemy.sprite.play("idle")

func physics_update(_delta: float) -> void:
	# Mismo chequeo de seguridad acá
	if not is_instance_valid(enemy.player): 
		return
	
	var dist = enemy.global_position.distance_to(enemy.player.global_position)
	if dist < vision_range:
		state_machine.transition_to("Chase")

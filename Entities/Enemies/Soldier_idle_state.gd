extends State

@onready var enemy = owner
@export var vision_range: float = 250.0 # Qué tan cerca tenés que estar para que te vea

func enter(_msg := {}) -> void:
	print("Soldado: Entrando a IDLE")
	enemy.velocity = Vector2.ZERO
	enemy.sprite.play("idle")

func physics_update(_delta: float) -> void:
	if not enemy.player: return
	
	# Si el jugador entra en su rango de visión, arranca a correr
	var dist = enemy.global_position.distance_to(enemy.player.global_position)
	if dist < vision_range:
		state_machine.transition_to("Chase")

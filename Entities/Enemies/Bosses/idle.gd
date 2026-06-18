extends State

@export var tiempo_espera: float = 2.0
var tiempo_restante: float = 0.0

func enter(_msg := {}) -> void:
	owner.velocity.x = 0
	owner.sprite.play("idle")
	tiempo_restante = tiempo_espera

func update(delta: float) -> void:
	if owner.esta_muerto: return
	
	tiempo_restante -= delta
	if tiempo_restante <= 0.0:
		# Seguridad: Verificamos si el jugador sigue vivo en la escena
		if not is_instance_valid(owner.player):
			tiempo_restante = tiempo_espera # Reinicia el loop si no hay nadie
			return
			
		# Inteligencia Artificial: Evaluamos el combo de ataques
		if owner.zarpazos_realizados < 2:
			state_machine.transition_to("ChaseZarpazo")
		else:
			state_machine.transition_to("ChaseJump")

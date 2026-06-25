extends State

var ya_despego: bool = false

func enter(_msg := {}) -> void:
	ya_despego = false
	owner.sprite.play("attack_jump")
	AudioManager.play_sfx("boss2_jump")
	
	if is_instance_valid(owner.player): 
		owner.mirar_hacia(owner.player.global_position)
		
		# Impulso vertical del salto
		owner.velocity.y = -380.0 
		
		# Calculamos dirección y le damos un boost de velocidad para caer encima
		var dir_x = sign(owner.player.global_position.x - owner.global_position.x)
		owner.velocity.x = dir_x * (owner.speed * 1.4)

	owner.sprite.animation_finished.connect(_on_animation_finished)

func physics_update(_delta: float) -> void:
	if owner.esta_muerto: return
	
	# Detectamos cuando el jefe efectivamente está en el aire
	if not ya_despego and not owner.is_on_floor():
		ya_despego = true
		
	# Si ya despegó y vuelve a tocar el suelo, frena el desplazamiento
	if ya_despego and owner.is_on_floor():
		owner.velocity.x = 0

func exit() -> void:
	if owner.sprite.animation_finished.is_connected(_on_animation_finished):
		owner.sprite.animation_finished.disconnect(_on_animation_finished)

func _on_animation_finished() -> void:
	if owner.sprite.animation == "attack_jump":
		owner.zarpazos_realizados = 0 # Reseteamos por completo el combo
		state_machine.transition_to("Idle")

extends State

@onready var player = owner

func enter(_msg := {}) -> void:
	# Frenamos al personaje
	player.velocity.x = 0
	player._animated_sprite.play("Crouch")
	# Ajustamos el muzzle para que no dispare desde el aire
	_actualizar_posicion_muzzle()

func physics_update(_delta: float) -> void:
	# Transición: Si suelta ABAJO, vuelve a Idle
	if not Input.is_action_pressed("ui_down"):
		state_machine.transition_to("Idle")
		return

	# Lógica de Disparo Agachado
	if Input.is_action_pressed("disparo"):
		# Forzamos que dispare horizontalmente según el flip
		var dir = Vector2.LEFT if player._animated_sprite.flip_h else Vector2.RIGHT
		player.get_node("WeaponComponent").disparar(dir)
	
	# Transición a Salto
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump")

func _actualizar_posicion_muzzle() -> void:
	# Como diseñador, podés ajustar este valor exacto 
	# para que coincida con tu sprite agachado
	player.muzzle.position = Vector2(10, 5)

extends State

@onready var player = owner

func enter(_msg := {}) -> void:
	# 1. Frenamos en seco al jugador horizontalmente
	player.velocity.x = 0
	
	# 2. Reproducimos la animación
	player._animated_sprite.play("Death")
	
	# 3. [Opcional pero muy recomendado] Apagamos su Hurtbox para que los 
	# enemigos no le sigan pegando al cadáver y saltando sangre o efectos.
	var hurtbox = player.get_node_or_null("HurtboxComponent")
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)
		
	# 4. Conectamos por código la señal para saber cuándo termina la animación
	if not player._animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player._animated_sprite.animation_finished.connect(_on_animation_finished)

func physics_update(_delta: float) -> void:
	# En este estado NO ESCUCHAMOS NINGÚN INPUT.
	# La gravedad se sigue aplicando automáticamente porque la tenés 
	# configurada en el _physics_process global de player.gd.
	pass

func _on_animation_finished():
	# Verificamos que la animación que terminó sea la de muerte
	if player._animated_sprite.animation == "Death":
		
		# Desconectamos la señal por prolijidad
		player._animated_sprite.animation_finished.disconnect(_on_animation_finished)
		
		# --- ACÁ OCURRE EL VERDADERO FINAL ---
		print("Animación de muerte terminada. Game Over.")
		
		# Podés llamar a un GameManager, emitir una señal global, o borrar el nodo.
		# Por ahora, volvemos a poner el queue_free() acá:
		

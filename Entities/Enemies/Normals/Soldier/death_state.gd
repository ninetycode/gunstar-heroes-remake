extends State

@onready var enemy = owner

func enter(_msg := {}) -> void:
	# 1. FRENAR CUALQUIER MOVIMIENTO PREVIO
	enemy.velocity = Vector2.ZERO
	
	# 2. EL SALTITO (Retroceso y Salto)
	# Si flip_h es true, mira a la izquierda, entonces salta a la derecha (1)
	var dir_salto = 1 if enemy.sprite.flip_h else -1
	
	# Valores más polenta para que se note
	enemy.velocity.x = dir_salto * 180  # Fuerza hacia atrás
	enemy.velocity.y = -500            # Fuerza hacia arriba
	
	# 3. APAGAR TODO EL DAÑO (Para que no sea un Sion)
	if enemy.hitbox:
		enemy.hitbox.monitoring = false
		enemy.hitbox.monitorable = false
	
	# Desactivamos la colisión con el jugador pero dejamos la del suelo
	# (Capa 4 suele ser la Hurtbox en tu setup)
	if enemy.has_node("HurtboxComponent/CollisionShape2D"):
		enemy.get_node("HurtboxComponent/CollisionShape2D").set_deferred("disabled", true)

	# 4. ANIMACIÓN
	if enemy.sprite.sprite_frames.has_animation("death"):
		enemy.sprite.play("death")
	
	# 5. DESVANECIMIENTO Y BORRADO
	# Esperamos a que termine el salto y la animación
	await get_tree().create_timer(1.2).timeout
	
	var tween = create_tween()
	tween.tween_property(enemy, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	enemy.queue_free()

func physics_update(_delta: float) -> void:
	# Importante: No ponemos velocity.x = 0 acá porque matamos el salto.
	# Dejamos que la fricción natural o el lerp lo frenen despacito.
	enemy.velocity.x = lerp(enemy.velocity.x, 0.0, 0.05)

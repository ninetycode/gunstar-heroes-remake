extends State

@onready var enemy = owner

func enter(_msg := {}) -> void:
	if randf() <= 0.5:
		# Lista de sonidos registrados en el AudioManager [cite: 59]
		var opciones_grito = ["soldier_death1", "soldier_death2"]
		var grito_elegido = opciones_grito.pick_random()
		
		# VARIACIÓN DE PITCH Y VOLUMEN:
		# Generamos un pitch aleatorio entre 0.9 (más grave) y 1.1 (más agudo)
		var pitch_variado = randf_range(0.9, 1.1)
		
		# Llamamos al AudioManager pasando el volumen deseado (-1.0) y el pitch calculado
		AudioManager.play_sfx(grito_elegido, -1.0, pitch_variado)

	# 2. FRENAR CUALQUIER MOVIMIENTO PREVIO
	enemy.velocity = Vector2.ZERO
	
	# 3. EL SALTITO (Retroceso y Salto)
	var dir_salto = 1 if enemy.sprite.flip_h else -1
	enemy.velocity.x = dir_salto * 180 
	enemy.velocity.y = -500           
	
	# 4. APAGAR TODO EL DAÑO
	if enemy.hitbox:
		enemy.hitbox.set_deferred("monitoring", false)
		enemy.hitbox.set_deferred("monitorable", false)
	
	if enemy.has_node("HurtboxComponent/CollisionShape2D"):
		enemy.get_node("HurtboxComponent/CollisionShape2D").set_deferred("disabled", true)

	# 5. ANIMACIÓN
	if enemy.sprite.sprite_frames.has_animation("death"):
		enemy.sprite.play("death")
	
	# 6. DESVANECIMIENTO Y BORRADO
	# El código se "pausa" acá, por eso el sonido debía estar arriba.
	await get_tree().create_timer(1.2).timeout
	
	var tween = create_tween()
	tween.tween_property(enemy, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	# La entidad se elimina de la memoria
	enemy.queue_free()

func physics_update(_delta: float) -> void:
	# Importante: No ponemos velocity.x = 0 acá porque matamos el salto.
	# Dejamos que la fricción natural o el lerp lo frenen despacito.
	enemy.velocity.x = lerp(enemy.velocity.x, 0.0, 0.05)

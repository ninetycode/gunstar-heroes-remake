extends State

@onready var enemy = owner

func enter(_msg := {}) -> void:
	# 1. El saltito hacia atrás
	# Si mira a la derecha (flip_h false), salta a la izquierda (-1)
	var dir_salto = 1 if enemy.sprite.flip_h else -1
	enemy.velocity.x = dir_salto * 120
	enemy.velocity.y = -500
	
	# 2. DESACTIVAR DAÑO (Hurtbox y Hitbox)
	# Desactivamos el Hurtbox para que no le entren más balas
	if enemy.has_node("HurtboxComponent/CollisionShape2D"):
		enemy.get_node("HurtboxComponent/CollisionShape2D").set_deferred("disabled", true)
	
	# Desactivamos el Hitbox para que el cadáver no dañe a Blue al tocarlo
	if enemy.has_node("HitboxComponent/CollisionShape2D"):
		enemy.get_node("HitboxComponent/CollisionShape2D").set_deferred("disabled", true)

	# NOTA: No tocamos el CollisionShape2D principal del enemigo, 
	# así el move_and_slide() sigue detectando el suelo y no se cae del mapa.

	# 3. Animación de muerte
	if enemy.sprite.sprite_frames.has_animation("death"):
		enemy.sprite.play("death")
	
	# 4. Esperar a que termine la animación y un ratito más en el suelo
	await enemy.sprite.animation_finished
	await get_tree().create_timer(1.5).timeout
	
	# 5. Desaparecer
	enemy.queue_free()

func physics_update(delta: float) -> void:
	# Aplicamos gravedad para que el salto sea una parábola y caiga al suelo
	if not enemy.is_on_floor():
		enemy.velocity.y += enemy.gravity * delta
	else:
		# Si toca el suelo, se va frenando horizontalmente
		enemy.velocity.x = lerp(enemy.velocity.x, 0.0, 0.1)

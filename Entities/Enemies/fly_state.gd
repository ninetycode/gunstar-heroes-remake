extends State

@onready var enemy = owner
var target_pos: Vector2
var change_timer = 0.0

func enter(_msg := {}) -> void:
	enemy.sprite.play("Fly") #

func physics_update(delta: float) -> void:
	change_timer -= delta
	if change_timer <= 0:
		var angle = randf() * TAU
		# Calculamos el punto alrededor de Blue
		var raw_target = enemy.player.global_position + Vector2(cos(angle), sin(angle)) * 250.0
		
		# --- RESTRICCIÓN DE ALTURA ---
		# Supongamos que tu pantalla mide 648px de alto. La mitad es 324.
		# Podés ajustar este número según tu nivel.
		var limite_superior = 324 
		
		# Si el punto elegido está por debajo del límite, lo subimos a la fuerza
		if raw_target.y > limite_superior:
			raw_target.y = limite_superior - randf_range(50, 150)
			
		target_pos = raw_target
		change_timer = randf_range(1.0, 2.5)

	# Movimiento suave hacia el target
	var dir = (target_pos - enemy.global_position).normalized()
	var separation = enemy.calcular_separacion()
	
	# Si por alguna razón el robot BAJA del límite, le damos un empujón extra hacia arriba
	if enemy.global_position.y > 350: 
		dir.y -= 2.0 # Fuerza hacia arriba

	enemy.velocity = enemy.velocity.lerp(dir * enemy.velocidad + separation, delta * 2.0)
	
	enemy.limitar_a_camara() 
	enemy.move_and_slide()
	
	enemy.sprite.flip_h = (enemy.player.global_position.x - enemy.global_position.x) > 0

	if enemy.can_shoot:
		state_machine.transition_to("AttackState")

extends Node2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT
var danio_actual: int = 0
@onready var sprite = $Sprite2D
@onready var hitbox_colision = $HitboxComponent/CollisionShape2D
var data_recurso: WeaponResource
var tipo_arma: WeaponResource.WeaponType
var target: Node2D = null
var turn_speed: float 

var tiempo_parpadeo: float = 0.0
var es_de_enemigo: bool = false 

# --- VARIABLE EXCLUSIVA DEL FUEGO ---
var tiempo_vida: float = 0.0

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(desactivar)
	
	if $HitboxComponent.has_signal("golpe_acertado"):
		# ¡Ojo acá! Cambiamos .connect(desactivar) por nuestra función personalizada
		$HitboxComponent.golpe_acertado.connect(_on_golpe_acertado)
		
	# Mantenemos también la de la pared por las dudas
	if $HitboxComponent.has_signal("choco_pared"):
		$HitboxComponent.choco_pared.connect(_on_choco_pared)

func _physics_process(delta):
	if es_de_enemigo:
		tiempo_parpadeo += delta * 20.0
		modulate = Color.RED if int(tiempo_parpadeo) % 2 == 0 else Color.CYAN

	if tipo_arma == WeaponResource.WeaponType.HOMING:
		actualizar_target_homing()
		if is_instance_valid(target):
			var desired_dir = (target.global_position - global_position).normalized()
			# El lerp hace que la bala doble suavemente hacia el enemigo
			direction = direction.lerp(desired_dir, turn_speed * delta).normalized()
			rotation = direction.angle()
	elif tipo_arma == WeaponResource.WeaponType.FIRE:
		# --- LA MAGIA DEL LANZALLAMAS ---
		tiempo_vida -= delta
		sprite.rotation += 15.0 * delta # Gira para parecer fuego vivo
		speed = move_toward(speed, 0, 1200 * delta) # Fricción: se va frenando de a poco
		
		# Calculamos qué tan "vieja" es la llama (de 0.0 a 1.0)
		var vida_maxima = 0.5
		var porcentaje_vida = 1.0 - (tiempo_vida / vida_maxima)
		
		# Evolución de texturas (Chica -> Mediana -> Grande)
		if data_recurso and data_recurso.bullet_textures.size() > 0:
			var tex_idx = 0
			if porcentaje_vida < 0.2: tex_idx = 0       # Nace chiquita
			elif porcentaje_vida < 0.4: tex_idx = 1     # Sigue chiquita
			elif porcentaje_vida < 0.7: tex_idx = 2     # Se vuelve mediana
			else: tex_idx = data_recurso.bullet_textures.size() - 1 # Explota grande al final
			
			# Nos aseguramos de no salirnos del límite del array
			tex_idx = clamp(tex_idx, 0, data_recurso.bullet_textures.size() - 1)
			sprite.texture = data_recurso.bullet_textures[tex_idx]

		if tiempo_vida <= 0:
			desactivar() 

	global_position += direction * speed * delta

func actualizar_target_homing():
	if es_de_enemigo:
		target = get_tree().get_first_node_in_group("Player")
	elif not is_instance_valid(target):
		target = buscar_enemigo_mas_cercano()

func buscar_enemigo_mas_cercano() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var closest = null
	var min_dist = INF 
	for enemy in enemies:
		if is_instance_valid(enemy):
			var dist = global_position.distance_squared_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = enemy
	return closest

func activar(pos: Vector2, dir: Vector2, data: WeaponResource, de_enemigo: bool = false, _fire_index: int = -1):
	if data == null: return
	data_recurso = data
	global_position = pos
	direction = dir
	rotation = dir.angle()
	es_de_enemigo = de_enemigo
	tiempo_parpadeo = 0.0 
	target = null 
	
	speed = data.velocidad_bala
	danio_actual = data.danio 
	scale = data.escala_bala 
	turn_speed = data.turn_speed
	tipo_arma = data.weapon_type
	
	# --- ASIGNACIÓN DE TEXTURAS SEGÚN EL ARMA ---
	if tipo_arma == WeaponResource.WeaponType.FIRE:
		tiempo_vida = 0.35 
		if data.bullet_textures.size() > 0:
			sprite.texture = data.bullet_textures[0] 
	else:
		sprite.texture = data.textura_bala
		sprite.rotation = 0 
	
	hitbox_colision.set_deferred("disabled", true)
	
	# --- BLINDAJE DE COLISIONES (LA MAGIA ACÁ) ---
	# 1. Por las dudas, apagamos todas las capas problemáticas para limpiar la bala reciclada
	$HitboxComponent.set_collision_mask_value(1, false) # Paredes
	$HitboxComponent.set_collision_mask_value(2, false) # Enemigos
	$HitboxComponent.set_collision_mask_value(4, false) # Player
	
	if es_de_enemigo:
		# BALA ENEMIGA: Solo busca al Player (Capa 4)
		$HitboxComponent.set_collision_mask_value(4, true)  
		
		$HitboxComponent.add_to_group("enemy_bullet")
		$HitboxComponent.remove_from_group("player_bullet")
		modulate = Color.RED
	else:
		# BALA DE BLUE: Siempre busca enemigos (Capa 2)
		$HitboxComponent.set_collision_mask_value(2, true) 
		
		# ¿Es el lanzallamas? Entonces TAMBIÉN busca paredes (Capa 1)
		if tipo_arma == WeaponResource.WeaponType.FIRE:
			$HitboxComponent.set_collision_mask_value(1, true)
		
		$HitboxComponent.add_to_group("player_bullet")
		$HitboxComponent.remove_from_group("enemy_bullet")
		modulate = Color.WHITE

	$HitboxComponent.danio = danio_actual
	visible = true
	set_physics_process(true)
	hitbox_colision.set_deferred("disabled", false)

func desactivar():
	if not visible: return
	visible = false
	set_physics_process(false)
	hitbox_colision.set_deferred("disabled", true)
	modulate = Color.WHITE 
	global_position = Vector2(-9999, -9999) 

func _on_golpe_acertado():
	# Si es FUEGO, NO se desactiva (lo atraviesa y sigue de largo).
	# Si es otra arma, desaparece.
	if tipo_arma != WeaponResource.WeaponType.FIRE:
		desactivar()
		
func _on_choco_pared():
	if tipo_arma == WeaponResource.WeaponType.FIRE:
		speed = 0 # Se amontona en la pared
	else:
		desactivar()

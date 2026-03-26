extends Node2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT
var danio_actual: int = 0
@onready var sprite = $Sprite2D
@onready var hitbox_colision = $HitboxComponent/CollisionShape2D

var tipo_arma: WeaponResource.WeaponType
var target: Node2D = null
var turn_speed: float 

var tiempo_parpadeo: float = 0.0
var es_de_enemigo: bool = false 

# --- VARIABLE EXCLUSIVA DEL FUEGO ---
var tiempo_vida: float = 0.0

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(desactivar)
	# Conectamos las señales de nuestra Hitbox actualizadas
	if $HitboxComponent.has_signal("golpe_acertado"):
		$HitboxComponent.golpe_acertado.connect(_on_golpe_acertado)
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
			direction = direction.lerp(desired_dir, turn_speed * delta).normalized()
			rotation = direction.angle()
			
	elif tipo_arma == WeaponResource.WeaponType.FIRE:
		# --- LÓGICA PURA DE LANZALLAMAS ---
		tiempo_vida -= delta
		sprite.rotation += 15.0 * delta # Rota caóticamente para parecer fuego vivo
		speed = move_toward(speed, 0, 1500 * delta) # Pierde velocidad de golpe simulando alcance
		
		if tiempo_vida <= 0:
			desactivar() # Se apaga de viejo

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

func activar(pos: Vector2, dir: Vector2, data: WeaponResource, de_enemigo: bool = false):
	if data == null: return

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
		tiempo_vida = 0.35 # Alcance máximo en segundos antes de desaparecer
		if data.bullet_textures.size() > 0:
			# Elige una llama random del array para que no sean todas iguales
			sprite.texture = data.bullet_textures.pick_random() 
	else:
		sprite.texture = data.textura_bala
		sprite.rotation = 0 # Enderezamos la imagen por si era una bala reciclada del lanzallamas
	
	hitbox_colision.set_deferred("disabled", true) 
	
	# Capa 1 es fundamental para que escuche a las paredes
	$HitboxComponent.set_collision_mask_value(1, true) 
	
	if es_de_enemigo:
		$HitboxComponent.set_collision_mask_value(2, false) 
		$HitboxComponent.set_collision_mask_value(4, true)  
		$HitboxComponent.add_to_group("enemy_bullet")
		$HitboxComponent.remove_from_group("player_bullet")
		modulate = Color.RED
	else:
		$HitboxComponent.set_collision_mask_value(4, false)
		$HitboxComponent.set_collision_mask_value(2, true) 
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

# --- MANEJO DE COLISIONES ---
func _on_golpe_acertado():
	# Si es fuego, no hacemos NADA para que atraviese a los enemigos.
	# Si es láser o homing, se destruye.
	if tipo_arma != WeaponResource.WeaponType.FIRE:
		desactivar()

func _on_choco_pared():
	if tipo_arma == WeaponResource.WeaponType.FIRE:
		# Si el fuego toca pared, su velocidad cae a 0 y se "amontona" ahí quemando
		speed = 0
	else:
		# Si un láser toca pared, explota/desaparece
		desactivar()

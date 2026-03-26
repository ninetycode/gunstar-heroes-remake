extends Node2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT
var danio_actual: int = 0
@onready var sprite = $Sprite2D
@onready var hitbox_colision = $HitboxComponent/CollisionShape2D

var tipo_arma: WeaponResource.WeaponType
var target: Node2D = null
var turn_speed: float 

# Para el efecto de parpadeo
var tiempo_parpadeo: float = 0.0
var es_de_enemigo: bool = false 

func _ready():
	# Conectamos las señales básicas
	$VisibleOnScreenNotifier2D.screen_exited.connect(desactivar)
	# Si tu HitboxComponent tiene esta señal, joya. Si no, usá area_entered.
	if $HitboxComponent.has_signal("golpe_acertado"):
		$HitboxComponent.golpe_acertado.connect(desactivar)

func _physics_process(delta):
	# 1. Lógica de parpadeo visual (Solo si es de enemigo)
	if es_de_enemigo:
		tiempo_parpadeo += delta * 20.0
		modulate = Color.RED if int(tiempo_parpadeo) % 2 == 0 else Color.CYAN

	# 2. Lógica de Homing (Seguimiento)
	if tipo_arma == WeaponResource.WeaponType.HOMING:
		actualizar_target_homing()
		if is_instance_valid(target):
			var desired_dir = (target.global_position - global_position).normalized()
			direction = direction.lerp(desired_dir, turn_speed * delta).normalized()
			rotation = direction.angle()
			
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

	# Reset de estado
	global_position = pos
	direction = dir
	rotation = dir.angle()
	es_de_enemigo = de_enemigo
	tiempo_parpadeo = 0.0 
	target = null # Limpiamos el target anterior
	
	# Datos del recurso
	speed = data.velocidad_bala
	danio_actual = data.danio 
	scale = data.escala_bala 
	turn_speed = data.turn_speed
	sprite.texture = data.textura_bala
	tipo_arma = data.weapon_type
	
	# BLINDAJE DE COLISIONES
	hitbox_colision.set_deferred("disabled", true) 
	
	if es_de_enemigo:
		$HitboxComponent.set_collision_mask_value(1, false) # No busca capa 1
		$HitboxComponent.set_collision_mask_value(2, false) # No busca capa 2 (no se suicida)
		$HitboxComponent.set_collision_mask_value(4, true)  # BUSCA CAPA 4 (Blue)
		
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
	global_position = Vector2(-9999, -9999) # La mandamos lejos

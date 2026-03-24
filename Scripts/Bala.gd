extends Node2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT
var danio_actual: int = 0
@onready var sprite = $Sprite2D
@onready var hitbox_colision = $HitboxComponent/CollisionShape2D
var tipo_arma: WeaponResource.WeaponType
var target: Node2D = null
var turn_speed: float = 6.0 # Qué tan rápido dobla la bala (ajustalo a gusto)

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(desactivar)
	# Nos conectamos a la señal que creamos antes en la Hitbox para reciclarnos
	$HitboxComponent.golpe_acertado.connect(desactivar)
	

func _physics_process(delta):
	# Si la bala es de tipo HOMING, ejecutamos la lógica de perseguir
	if tipo_arma == WeaponResource.WeaponType.HOMING:
		
		# Si no tenemos objetivo, o el objetivo ya murió (queue_free), buscamos uno nuevo
		if not is_instance_valid(target):
			target = buscar_enemigo_mas_cercano()
			
		# Si encontramos un objetivo válido, doblamos hacia él
		if is_instance_valid(target):
			var desired_dir = (target.global_position - global_position).normalized()
			# El LERP hace que doble de a poco. Si cambiás turn_speed, dobla más brusco o más abierto
			direction = direction.lerp(desired_dir, turn_speed * delta).normalized()
			rotation = direction.angle()
			
	# Finalmente, la movemos hacia adelante (sea normal o homing)
	global_position += direction * speed * delta

# Función para escanear el escenario y quedarse con el más cerca
func buscar_enemigo_mas_cercano() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	if enemies.is_empty(): 
		return null
		
	var closest = null
	# Usamos infinito como base para empezar a comparar
	var min_dist = INF 
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var dist = global_position.distance_squared_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = enemy
				
	return closest

func activar(pos: Vector2, dir: Vector2, data: WeaponResource):
	global_position = pos
	direction = dir
	rotation = dir.angle()
	
	speed = data.velocidad_bala
	danio_actual = data.danio 
	scale = data.escala_bala 
	
	# Le pasamos el daño al componente
	$HitboxComponent.danio = danio_actual
		
	visible = true
	sprite.texture = data.textura_bala
	set_physics_process(true)
	hitbox_colision.set_deferred("disabled", false)
	
	tipo_arma = data.weapon_type
	target = null # Reiniciamos la mira
	

func desactivar():
	visible = false
	set_physics_process(false)
	hitbox_colision.set_deferred("disabled", true)
	global_position = Vector2(-9999, -9999)

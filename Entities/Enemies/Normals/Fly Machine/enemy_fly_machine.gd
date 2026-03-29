# enemy_fly_machine.gd
extends BaseEnemy

@export var velocidad = 120.0
@export var fuerza_separacion = 400.0
@onready var state_machine: StateMachine = $StateMachine
@onready var shoot_timer: Timer = $ShootTimer # Necesitás crear este nodo en la escena
@export var altura_minima_suelo = 150.0 # Distancia mínima sobre el suelo
@export var bullet_scene: PackedScene = preload("res://Scenes/Bullet.tscn")
@export var mi_arma_resource : WeaponResource
var can_shoot: bool = false

func _ready() -> void:
	super() # Esto ejecuta el _ready de BaseEnemy (busca al player y conecta señales)
	add_to_group("enemigos")

# SOBREESCRIBIMOS la función de daño para que use la StateMachine
func _on_danio_recibido(_cantidad: int):
	# Ejecutamos el parpadeo blanco heredado de BaseEnemy
	super(_cantidad)
	
	# Y ADEMÁS, lo mandamos al estado de Hit para que haga su animación especial
	if state_machine:
		state_machine.transition_to("HitState")



# Estas funciones las usaremos dentro de los Estados (FlyState)
func calcular_separacion() -> Vector2:
	var fuerza = Vector2.ZERO
	var areas = $HurtboxComponent.get_overlapping_areas()
	for area in areas:
		if area != $HurtboxComponent and area.owner.is_in_group("enemigos"):
			var dif = global_position - area.global_position
			fuerza += dif.normalized() * (fuerza_separacion / max(dif.length(), 1.0))
	return fuerza

func limitar_a_camara():
	var cam = get_viewport().get_camera_2d()
	if cam:
		var screen_size = get_viewport_rect().size / cam.zoom
		var cam_pos = cam.get_screen_center_position()
		
		# Límites laterales
		global_position.x = clamp(global_position.x, cam_pos.x - screen_size.x/2 + 30, cam_pos.x + screen_size.x/2 - 30)
		
		# Límite vertical: No dejar que baje del 70% de la altura de la cámara
		var techo = cam_pos.y - screen_size.y/2 + 50
		var suelo_maximo = cam_pos.y + (screen_size.y/2) * 0.4 # Esto lo mantiene en la mitad superior
		
		global_position.y = clamp(global_position.y, techo, suelo_maximo)

func disparar_a_jugador():
	if mi_arma_resource == null: return # Seguridad
	
	# --- VALIDACIÓN CRÍTICA DE ARQUITECTURA ---
	# Previene el crash verificando que el nodo del jugador siga vivo en la memoria.
	if not is_instance_valid(player):
		return
	
	var dir = (player.global_position - global_position).normalized()
	# Invocamos la bala con el parpadeo y los datos del láser
	BulletPool.get_bullet(global_position, dir, mi_arma_resource, true)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true # Le avisamos al estado que ya podemos disparar

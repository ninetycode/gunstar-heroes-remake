# enemy_fly_machine.gd
extends BaseEnemy

@export var velocidad = 120.0
@export var fuerza_separacion = 400.0
@onready var state_machine: StateMachine = $StateMachine
@onready var shoot_timer: Timer = $ShootTimer # Necesitás crear este nodo en la escena

var can_shoot: bool = false # <--- ESTA ES LA QUE FALTA
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

# Conectamos la señal del HurtboxComponent (desde el Editor o por código)
func _on_hurtbox_component_area_entered(hitbox: Area2D) -> void:
	if hitbox.is_in_group("player_bullet"):
		# Llamamos a la función de tu StatsComponent
		stats.recibir_danio(1) 
		
		# Forzamos la transición al estado de Hit
		state_machine.transition_to("HitState")
		
		if hitbox.has_method("destroy"):
			hitbox.destroy()

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
		global_position.x = clamp(global_position.x, cam_pos.x - screen_size.x/2 + 30, cam_pos.x + screen_size.x/2 - 30)
		global_position.y = clamp(global_position.y, cam_pos.y - screen_size.y/2 + 30, cam_pos.y + screen_size.y/2 - 30)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true # Le avisamos al estado que ya podemos disparar

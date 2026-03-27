extends BossEnemy # Heredamos de tu clase oficial de jefes

# Exportamos el recurso .tres de la espora que ya tenés implementado
@export var arma_espora: WeaponResource

# Referencias a nodos hijos
@onready var muzzle_marker: Marker2D = $MuzzleMarker
@onready var state_machine: StateMachine = $StateMachine

# Timer para controlar los ataques (necesitás crearlo en la escena)
@onready var attack_timer: Timer = $ShootTimer

func _ready():
	super() # Ejecuta BossEnemy._ready (avisa a la UI, busca al player)
	nombre_boss = "Planta Mutante Zigzag"

# Esta función la llama el LockZone
func empezar_pelea():
	# Activamos la StateMachine o el timer de ataque inicial
	# Si usás StateMachine, hacé un transition_to acá.
	if attack_timer:
		attack_timer.start()

# --- EL PATRÓN DE ATAQUE LLUVIOSO ---
# Esta función se llama cuando el timer de ataque o la StateMachine lo decidan.
func ataque_patron_lluvia_zigzag():
	if not arma_espora: return
	
	var spawn_pos = muzzle_marker.global_position
	var cantidad_esporas = 15 # <--- Subimos a 15 para que sea una lluvia real
	
	for i in range(cantidad_esporas):
		# Ángulo bien abierto para que cubra la pantalla
		var dir = Vector2.UP.rotated(randf_range(-1.2, 1.2))
		# Variamos velocidad para que no caigan todas en fila
		var recurso_temp = arma_espora.duplicate()
		recurso_temp.velocidad_bala = arma_espora.velocidad_bala * randf_range(0.7, 1.3)
		
		BulletPool.get_bullet(spawn_pos, dir, recurso_temp, true)

func _on_danio_recibido(cantidad: int):
	super(cantidad) # Mantiene el parpadeo blanco
	
	# Efecto de "curvada" o sacudida por dolor
	var tween = create_tween()
	# Se inclina rápido hacia un lado y vuelve
	tween.tween_property(sprite, "skew", 0.2, 0.05) 
	tween.tween_property(sprite, "skew", -0.2, 0.05)
	tween.tween_property(sprite, "skew", 0.0, 0.1)
	
	# Si querés que también se "achique" un poco por el golpe:
	var tween_scale = create_tween()
	tween_scale.tween_property(sprite, "scale", Vector2(1.1, 0.8), 0.05) # Se aplasta
	tween_scale.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1) # Vuelve al original

func _on_death():
	# Buscamos la cámara en el grupo o por referencia para desbloquearla
	var camara = get_viewport().get_camera_2d()
	if camara and camara.has_method("desbloquear_camara"):
		camara.desbloquear_camara()
	
	# Llamamos al super para que ejecute la lógica de BossEnemy (partículas, morir, etc.)
	super()

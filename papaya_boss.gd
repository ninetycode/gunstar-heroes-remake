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
	var cantidad = 4 # Cuántas esporas tira por ráfaga
	
	for i in range(cantidad):
		# Generamos un ángulo que no sea 100% vertical para que no se escapen tan rápido
		# -0.8 a 0.8 radianes hace un abanico hacia arriba
		var angulo_random = randf_range(-0.8, 0.8)
		var dir = Vector2.UP.rotated(angulo_random)
		
		# Usamos tu BulletPool
		BulletPool.get_bullet(spawn_pos, dir, arma_espora, true)
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

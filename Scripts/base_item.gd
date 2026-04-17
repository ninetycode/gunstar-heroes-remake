extends Area2D
class_name BaseItem

@export var item_texture: Texture2D
@export var float_amplitude: float = 5.0
@export var float_speed: float = 4.0
@export var fall_speed: float = 150.0 # Qué tan rápido cae al piso

var time_passed: float = 0.0
var start_y: float = 0.0
var toco_piso: bool = false

# Asumimos que los hijos tendrán un RayCast2D llamado "FloorDetector"
@onready var raycast: RayCast2D = $FloorDetector 

func _ready() -> void:
	add_to_group("LootItems")
	
	# Seteamos la textura si el hijo tiene un Sprite2D
	if item_texture and has_node("Sprite2D"):
		$Sprite2D.texture = item_texture
		
	body_entered.connect(_on_body_entered)
	
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _process(delta: float) -> void:
	if not toco_piso:
		# CAÍDA HASTA TOCAR EL PISO
		position.y += fall_speed * delta
		
		# Si el raycast detecta el suelo (Capa 1)
		if raycast and raycast.is_colliding():
			toco_piso = true
			# Guardamos este punto como el "ancla" para flotar
			start_y = position.y 
	else:
		# FLOTE SENOIDAL (Solo arranca cuando ya tocó el piso)
		time_passed += delta
		position.y = start_y + (sin(time_passed * float_speed) * float_amplitude)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Llamamos a la función única de cada hijo. 
		# Si devuelve 'true', significa que lo agarró exitosamente y se borra.
		if aplicar_efecto(body):
			queue_free()

# --- FUNCIÓN VIRTUAL ---
# Los scripts hijos VAN A SOBRESCRIBIR esta función con su propia lógica.
func aplicar_efecto(_player: Node2D) -> bool:
	return false

extends CharacterBody2D
class_name BaseEnemy
# El rango en el inspector va a ser un deslizador de 0 a 100%
@export_range(0.0, 100.0) var drop_chance: float = 25.0 
# Acá vas a arrastrar tu escena health_item.tscn
@export var loot_scene: PackedScene
signal enemy_died(enemy_node: Node) # NUEVA SEÑAL

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null
var is_ambush: bool = false 
@onready var sprite = $AnimatedSprite2D
@onready var stats = $StatsComponent

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if stats:
		stats.salud_agotada.connect(_on_death)
		stats.danio_recibido.connect(_on_danio_recibido)
	add_to_group("Enemies")

func _on_danio_recibido(_cantidad: int):
	if sprite:
		sprite.modulate = Color(10, 10, 10)
		await get_tree().create_timer(0.05).timeout
		sprite.modulate = Color(1, 1, 1)

func _on_death():
	# Emitimos la señal antes de hacer cualquier otra cosa
	enemy_died.emit(self) 
	generar_drop()
	queue_free()
	
func generar_drop(es_vip: bool = false) -> void:
	# 1. Seguridad básica
	if loot_scene == null:
		return
		
	# --- VIEJO LÍMITE ELIMINADO PARA EL ROGUE-LITE ---
	# Borramos la lógica de "items_activos >= 1" para que todos 
	# los enemigos puedan dropear libremente sus escudos y joyas.

	# 2. Tiramos los dados
	var roll = randf_range(0.0, 100.0)
	
	# 3. Si sacamos menos que la chance (o si es el jefe VIP que siempre dropea)
	if roll <= drop_chance or es_vip:
		var item = loot_scene.instantiate()
		item.global_position = self.global_position
		
		# Lo agregamos al mundo de forma segura
		get_tree().current_scene.call_deferred("add_child", item)
		
func obtener_punto_apuntado() -> Vector2:
	# Buscamos si el enemigo tiene un HurtboxComponent
	var hurtbox = get_node_or_null("HurtboxComponent")
	
	if hurtbox:
		# Si lo tiene, devolvemos las coordenadas de esa caja de daño (la cabeza de tu jefe)
		return hurtbox.global_position
		
	# Si por algún motivo no tiene, devolvemos la posición normal como plan B
	return global_position

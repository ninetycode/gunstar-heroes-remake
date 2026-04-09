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
	
func generar_drop() -> void:
	if loot_scene == null:
		return
		
	# --- LÍMITE DE DROPS ---
	# Preguntamos cuántos ítems existen actualmente en todo el nivel
	var items_activos = get_tree().get_nodes_in_group("LootItems")
	
	# Si ya hay 1 (o más), cortamos la ejecución y el enemigo no suelta nada
	if items_activos.size() >= 1:
		return
		
	# Si pasamos el filtro (size es 0), recién ahí tiramos los dados
	var roll = randf_range(0.0, 100.0)
	
	if roll <= drop_chance:
		var item = loot_scene.instantiate()
		item.global_position = self.global_position
		get_tree().current_scene.call_deferred("add_child", item)

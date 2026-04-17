extends CharacterBody2D
class_name BaseEnemy

@export_category("Loot (Botín)")
# 1. El Dado Global: ¿Suelta algo?
@export_range(0.0, 100.0) var probabilidad_dropear_algo: float = 25.0 
# 2. La Tabla de Botín: ¿Qué suelta?
@export var posibles_drops: Array[DropConfig] = []

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
	# 1. Seguridad: Si no tiene drops configurados, no hacemos nada
	if posibles_drops.is_empty():
		return
		
	# 2. DADO GLOBAL (¿Dropea algo?)
	var roll_global = randf_range(0.0, 100.0)
	
	# Si no superó la chance y NO es vip, se queda sin dropear nada
	if roll_global > probabilidad_dropear_algo and not es_vip:
		return 

	# 3. DADO DE ÍTEM (SÍ va a dropear, elegimos cuál)
	# Primero sumamos los pesos de todos los ítems válidos
	var peso_total = 0
	for drop in posibles_drops:
		if drop != null and drop.item_scene != null:
			peso_total += drop.peso
			
	if peso_total == 0:
		return # Seguridad por si todos los pesos están en 0
		
	# Tiramos un número entre 1 y el peso total
	var roll_item = randi_range(1, peso_total)
	var peso_acumulado = 0
	var item_elegido: PackedScene = null
	
	# Revisamos a qué ítem le tocó el número ganador
	for drop in posibles_drops:
		if drop != null and drop.item_scene != null:
			peso_acumulado += drop.peso
			if roll_item <= peso_acumulado:
				item_elegido = drop.item_scene
				break # Encontramos el ítem, cortamos el bucle
				
	# 4. INSTANCIAR EL ÍTEM ELEGIDO
	if item_elegido:
		var item_instanciado = item_elegido.instantiate()
		item_instanciado.global_position = self.global_position
		get_tree().current_scene.call_deferred("add_child", item_instanciado)
		
func obtener_punto_apuntado() -> Vector2:
	# Buscamos si el enemigo tiene un HurtboxComponent
	var hurtbox = get_node_or_null("HurtboxComponent")
	
	if hurtbox:
		# Si lo tiene, devolvemos las coordenadas de esa caja de daño (la cabeza de tu jefe)
		return hurtbox.global_position
		
	# Si por algún motivo no tiene, devolvemos la posición normal como plan B
	return global_position

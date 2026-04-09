extends Area2D

@export var heal_amount: int = 20
@export var item_texture: Texture2D

# --- VARIABLES PARA EL FLOTE ---
@export var float_amplitude: float = 5.0 # Cuántos píxeles sube y baja
@export var float_speed: float = 4.0     # Qué tan rápido flota

var time_passed: float = 0.0
var start_y: float = 0.0

func _ready() -> void:
	add_to_group("LootItems")
	if item_texture:
		$Sprite2D.texture = item_texture
		
	# Guardamos la altura original en la que "nació" el ítem al caer del enemigo
	start_y = position.y
		
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# --- ANIMACIÓN DE FLOTE MATEMÁTICA ---
	time_passed += delta
	# Calculamos la nueva posición Y sumándole la onda senoidal a la posición original
	position.y = start_y + (sin(time_passed * float_speed) * float_amplitude)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player_stats = body.get_node_or_null("StatsComponent")
		
		if player_stats and player_stats.vida_actual < player_stats.vida_maxima:
			# Lo curamos
			player_stats.curar(heal_amount)
			
			# --- EFECTO DE SONIDO ---
			# Llamamos a tu AudioManager global justo antes de destruirnos.
			# (Asegurate de cambiar "heal_sound" por el nombre real de tu pista en el AudioManager)
			AudioManager.play_sfx("curacion", -1.0)
			
			# Nos destruimos
			queue_free()

class_name ArenaManager
extends Node2D

@export_category("Zonas del Pasillo")
@export var zona_inicio: Area2D
@export var zona_fin: Area2D
@export var spawner: SpawnerManager

@export_category("Audio")
## Escribí acá el nombre de la pista tal cual lo lee tu AudioManager (ej: "boss_theme")
@export var arena_music: String = ""
var arena_completada: bool = false

func _ready() -> void:
	assert(zona_inicio != null, "Falta asignar la zona de inicio")
	assert(zona_fin != null, "Falta asignar la zona de fin")
	
	zona_inicio.body_entered.connect(_on_inicio_body_entered) # 
	zona_fin.body_entered.connect(_on_fin_body_entered) # 
	
	# --- ADAPTACIÓN PARA JEFES ---
	if spawner != null:
		# Es una sala normal con hordas
		spawner.all_waves_completed.connect(_on_arena_completada) # 
	else:
		# Es una sala de jefe (no hay spawner). Escuchamos la señal de tu BaseBoss
		GameEvents.boss_died.connect(_on_arena_completada)

func _on_inicio_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		zona_inicio.set_deferred("monitoring", false)
		
		# [Inferencia] Asumo que tu AudioManager tiene un método parecido a este. 
		# Cambiá "play_music" por la función real que usen con Facu.
		if arena_music != "nivel_1":
			AudioManager.play_music(arena_music)
			
		spawner.start_spawning()

func _on_fin_body_entered(body: Node2D) -> void:
	# --- NUEVA REGLA: Si la arena no se completó, no hacemos nada ---
	if not arena_completada:
		return 

	if body.is_in_group("Player"):
		var stats = body.get_node_or_null("StatsComponent")
		if stats:
			GameManager.guardar_estado_jugador(stats.vida_actual, stats.escudo_actual, stats.monedas_actuales)
			
		zona_fin.set_deferred("monitoring", false)
		if spawner:
			spawner.stop_spawning()
		get_tree().call_group("HUD_Group", "mostrar_cartel_go", false)
		
		# Avanzamos de habitación
		if LevelManager.has_method("avanzar_habitacion"):
			LevelManager.avanzar_habitacion()
			
func _on_arena_completada():
	# --- ABRIMOS EL CANDADO ---
	arena_completada = true 
	get_tree().call_group("HUD_Group", "mostrar_cartel_go", true)
	
	# Opcional (Pared Física): Si tenés una pared invisible que bloquea el paso, la borramos acá
	var pared_derecha = get_node_or_null("ParedDerecha")
	if pared_derecha:
		pared_derecha.queue_free()

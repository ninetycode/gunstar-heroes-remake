class_name ArenaManager
extends Node2D

# --- NUEVO: INTERRUPTOR A PRUEBA DE BALAS ---
@export_enum("Horda", "Jefe") var tipo_de_sala: int = 0

@export_category("Zonas del Pasillo")
@export var zona_inicio: Area2D
@export var zona_fin: Area2D
@export var spawner: SpawnerManager

@export_category("Audio")
@export var arena_music: String = ""
var arena_completada: bool = false

func _ready() -> void:
	assert(zona_inicio != null, "Falta asignar la zona de inicio")
	assert(zona_fin != null, "Falta asignar la zona de fin")
	
	zona_inicio.body_entered.connect(_on_inicio_body_entered)
	zona_fin.body_entered.connect(_on_fin_body_entered)
	
	# --- NUEVA LÓGICA EXPLICITA ---
	if tipo_de_sala == 0: # Si en el inspector elegiste "Horda"
		if spawner != null:
			spawner.all_waves_completed.connect(_on_arena_completada) 
	else: # Si en el inspector elegiste "Jefe"
		# Ignoramos completamente al spawner y escuchamos al Boss
		GameEvents.boss_died.connect(_on_arena_completada)

func _on_inicio_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		zona_inicio.set_deferred("monitoring", false)
		
		var camara = get_viewport().get_camera_2d()
		if camara and camara.has_method("bloquear_en_posicion"):
			# Pasamos la posición X y si es jefe (tipo_de_sala == 1 es Jefe)
			var es_jefe = (tipo_de_sala == 1)
			camara.bloquear_en_posicion(global_position.x, es_jefe)

		if tipo_de_sala == 0 and spawner != null:
			spawner.start_spawning()

# ... (Acá dejá tus funciones _on_fin_body_entered y _on_arena_completada tal cual las tenías) ...

func _on_fin_body_entered(body: Node2D) -> void:
	if not arena_completada:
		return 

	if body.is_in_group("Player"):
		var stats = body.get_node_or_null("StatsComponent")
		var wallet = body.get_node_or_null("WalletComponent") # <-- Buscamos la billetera
		
		if stats:
			# Si por alguna razón no hay billetera, usamos el valor global como respaldo para evitar crasheos
			var monedas_guardar = wallet.monedas_actuales if wallet else GameManager.monedas_totales
			
			GameManager.guardar_estado_jugador(stats.vida_actual, stats.escudo_actual, monedas_guardar)
			
		zona_fin.set_deferred("monitoring", false)
		if spawner:
			spawner.stop_spawning()
		get_tree().call_group("HUD_Group", "mostrar_cartel_go", false)
		
		if LevelManager.has_method("avanzar_habitacion"):
			LevelManager.avanzar_habitacion()

func _on_arena_completada() -> void:
	arena_completada = true
	get_tree().call_group("HUD_Group", "mostrar_cartel_go", true)
	
	# --- NUEVO: Avisamos a la cámara que ya puede seguir avanzando ---
	var camara = get_viewport().get_camera_2d()
	if camara and camara.has_method("permitir_avance"):
		camara.permitir_avance()

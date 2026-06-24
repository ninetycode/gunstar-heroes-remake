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
		
		if tipo_de_sala == 0: # Si es sala normal de Horda
			if spawner != null:
				spawner.start_spawning()
		else: # Si elegiste tipo "Jefe"
			# 1. Le pedimos al LevelManager los datos del nivel actual
			if LevelManager.config_actual:
				var config = LevelManager.config_actual
				if config.musica_jefe != "":
					# 2. Hacemos que la música de hordas se apague en 0.8 segundos
					AudioManager.stop_music(0.8)
					# Esperamos un instante breve para que no se pisen de golpe
					await get_tree().create_timer(0.4).timeout
					# 3. Encendemos la música del jefe con un fade de 1.2 segundos
					AudioManager.play_music(config.musica_jefe, 0.0, 1.2)

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
			
func _on_arena_completada():
	# --- ABRIMOS EL CANDADO ---
	arena_completada = true 
	get_tree().call_group("HUD_Group", "mostrar_cartel_go", true)
	
	# Opcional (Pared Física): Si tenés una pared invisible que bloquea el paso, la borramos acá
	var pared_derecha = get_node_or_null("ParedDerecha")
	if pared_derecha:
		pared_derecha.queue_free()

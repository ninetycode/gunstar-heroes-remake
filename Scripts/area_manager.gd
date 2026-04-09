class_name ArenaManager
extends Node2D

@export_category("Zonas del Pasillo")
@export var zona_inicio: Area2D
@export var zona_fin: Area2D
@export var spawner: SpawnerManager

@export_category("Audio")
## Escribí acá el nombre de la pista tal cual lo lee tu AudioManager (ej: "boss_theme")
@export var arena_music: String = ""

func _ready() -> void:
	assert(zona_inicio != null, "Falta asignar la zona de inicio")
	assert(zona_fin != null, "Falta asignar la zona de fin")
	assert(spawner != null, "Falta asignar el spawner")

	zona_inicio.body_entered.connect(_on_inicio_body_entered)
	zona_fin.body_entered.connect(_on_fin_body_entered)

func _on_inicio_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		zona_inicio.set_deferred("monitoring", false)
		
		# [Inferencia] Asumo que tu AudioManager tiene un método parecido a este. 
		# Cambiá "play_music" por la función real que usen con Facu.
		if arena_music != "nivel_1":
			AudioManager.play_music(arena_music)
			
		spawner.start_spawning()

func _on_fin_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		zona_fin.set_deferred("monitoring", false)
		spawner.stop_spawning()
		
		# Detenemos la música al cruzar la meta con un fade_out de 2 segundos
		#if arena_music != "":
			#AudioManager.stop_music(2.0)

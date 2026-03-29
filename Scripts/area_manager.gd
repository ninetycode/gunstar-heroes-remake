class_name ArenaManager
extends Node2D

@export_category("Zonas del Pasillo")
@export var zona_inicio: Area2D
@export var zona_fin: Area2D
@export var spawner: SpawnerManager

func _ready() -> void:
	# Validaciones
	assert(zona_inicio != null, "Falta asignar la zona de inicio")
	assert(zona_fin != null, "Falta asignar la zona de fin")
	assert(spawner != null, "Falta asignar el spawner")

	# Conectamos ambos gatillos
	zona_inicio.body_entered.connect(_on_inicio_body_entered)
	zona_fin.body_entered.connect(_on_fin_body_entered)

func _on_inicio_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		zona_inicio.set_deferred("monitoring", false) # Se apaga para no repetir
		spawner.start_spawning()

func _on_fin_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		zona_fin.set_deferred("monitoring", false) # Se apaga la meta
		spawner.stop_spawning() # Le avisamos al spawner que corte todo

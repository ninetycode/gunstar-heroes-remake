class_name ArenaManager
extends Node2D

@export_category("Componentes de la Arena")
@export var trigger_zone: Area2D
@export var camera: Camera2D
@export var spawner: SpawnerManager

func _ready() -> void:
	# Validaciones de arquitectura para evitar crasheos silenciosos
	assert(trigger_zone != null, "Falta asignar el trigger_zone en ArenaManager")
	assert(camera != null, "Falta asignar la cámara en ArenaManager")
	assert(spawner != null, "Falta asignar el spawner en ArenaManager")

	# Conexión de señales
	trigger_zone.body_entered.connect(_on_trigger_body_entered)
	spawner.all_waves_completed.connect(_on_arena_completed)

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# 1. Ejecutar "La Jaula"
		if camera.has_method("bloquear_camara"):
			camera.bloquear_camara()

		# 2. Apagar el trigger para evitar doble ejecución
		trigger_zone.set_deferred("monitoring", false)

		# 3. Iniciar el combate Data-Driven
		spawner.start_spawning()

func _on_arena_completed() -> void:
	# 1. Liberar "La Jaula"
	if camera.has_method("desbloquear_camara"):
		camera.desbloquear_camara()

	# 2. Opcional: Emitir señal global para mostrar UI de "GO RIGHT"
	# EventBus.emit_signal("show_go_right_indicator")
	
	queue_free() # Destruye el orquestador ya que la arena fue superada

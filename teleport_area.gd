extends Area2D

@export_file("*.tscn") var escena_destino: String

func _ready() -> void:
	# Conectamos la señal de forma segura
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verificamos que sea el jugador y que la ruta no esté vacía
	if body.is_in_group("Player") and not escena_destino.is_empty():
		iniciar_viaje_diferido.call_deferred()

func iniciar_viaje_diferido() -> void:
	# Le pasamos la escena que configuraste en el Inspector de ese nodo en particular
	TransitionManager.viajar_a(escena_destino)

extends Area2D

# Ruta hacia el Lobby (podés cambiarla desde el inspector)
@export_file("*.tscn") var ruta_lobby: String = "res://Levels/Lobby.tscn"

func _ready() -> void:
	# Conectamos la señal automáticamente por código
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Usamos la Opción B (diferir la llamada) para evitar problemas de físicas
		iniciar_viaje_diferido.call_deferred()

func iniciar_viaje_diferido() -> void:
	# Llamamos a tu TransitionManager (asumiendo que es un Autoload)
	# y le pasamos la ruta del nivel al que queremos ir
	TransitionManager.viajar_a(ruta_lobby)

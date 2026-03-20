extends CharacterBody2D

@onready var stats = $StatsComponent
@onready var sprite = $AnimatedSprite2D

func _ready():
	# Cuando la salud llegue a 0, el enemigo desaparece
	stats.salud_agotada.connect(_on_death)

func _on_death():
	# Acá podrías poner una animación de explosión
	queue_free() 

# Esta función la va a llamar la bala al chocar
func recibir_danio(cantidad: int):
	stats.quitar_vida(cantidad)
	# Feedback visual simple: parpadea en rojo
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).seconds
	sprite.modulate = Color.WHITE

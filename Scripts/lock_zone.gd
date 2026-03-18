extends Area2D

@export var camara_path: NodePath
@onready var camara = get_node(camara_path)

func _on_body_entered(body):
	if body.name == "GunstarBlue2":
		camara.bloquear_camara()
		# Aquí podrías disparar el evento: spawnear enemigos, etc.
		iniciar_evento_combate()

func iniciar_evento_combate():
	# Ejemplo: Esperar a que los enemigos mueran
	# Por ahora, simulamos un tiempo para probar:
	await get_tree().create_timer(5.0).timeout
	finalizar_evento()

func finalizar_evento():
	camara.desbloquear_camara()
	queue_free() # Eliminamos la zona para que no se bloquee de nuevo

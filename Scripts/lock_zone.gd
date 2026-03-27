extends Area2D

@export var camara: Camera2D 
@export var jefe_papaya: CharacterBody2D # Arrastrá al Jefe Papaya acá

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Usamos grupos para que sea infalible
	if body.is_in_group("Player"):
		if camara and camara.has_method("bloquear_camara"):
			camara.bloquear_camara()
		
		# ESTO ES LO QUE ACTIVA AL JEFE
		if jefe_papaya and jefe_papaya.has_method("empezar_pelea"):
			jefe_papaya.empezar_pelea()
			
		set_deferred("monitoring", false) # Se apaga para no repetir

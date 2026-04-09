extends Area2D

@export var camara: Camera2D 
@export var jefe_papaya: CharacterBody2D 

func _ready():
	# Conectamos la señal si no está conectada en el inspector
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player") or body.name == "GunstarBlue":
		print("¡Entrando a zona de pelea!") # Esto te confirma que el trigger funciona
		
		if camara and camara.has_method("bloquear_camara"):
			camara.bloquear_camara()
		
		if jefe_papaya and jefe_papaya.has_method("empezar_pelea"):
			jefe_papaya.empezar_pelea()
			
		set_deferred("monitoring", false)

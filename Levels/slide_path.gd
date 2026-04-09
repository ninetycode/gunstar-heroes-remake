#extends Node2D

#@export var tiempo_de_bajada: float = 30.0 
#@export var velocidad_rampa: Vector2 = Vector2(-600, -600) 
#@export var velocidad_cielo: Vector2 = Vector2(-150, 0) 

#@onready var parallax_cielo = $ParallaxCielo # Nodo Parallax2D
#@onready var parallax_rampa = $ParallaxRampa # Nodo Parallax2D
#@onready var muro_inferior = $MuroInvisibleInferior 
#@onready var timer = $Timer

#func _ready():
	#timer.timeout.connect(_on_timer_timeout)

#func iniciar_secuencia():
	#timer.start(tiempo_de_bajada)
	
	# Encendemos la cinta de correr usando la propiedad nativa de Godot 4.3+
	#parallax_cielo.autoscroll = velocidad_cielo
	#parallax_rampa.autoscroll = velocidad_rampa
	
	# Bloqueamos cámara
	#var camara = get_viewport().get_camera_2d()
	#if camara and camara.has_method("bloquear_camara"):
		#camara.bloquear_camara()
		
	# ¡Forzamos a Blue a entrar en el estado de deslizamiento!
	#var player = get_tree().current_scene.find_child("GunstarBlue", true, false)
	#if player and player.has_node("StateMachine"): # Cambiá "StateMachine" por el nombre de tu nodo
		#player.get_node("StateMachine").transition_to("SlideState")

#func _on_timer_timeout():
	# Frenamos los fondos
	#parallax_cielo.autoscroll = Vector2.ZERO
	#parallax_rampa.autoscroll = Vector2.ZERO
	
	#if muro_inferior:
		#muro_inferior.queue_free()
		
	#var camara = get_viewport().get_camera_2d()
	#if camara and camara.has_method("desbloquear_camara"):
		#camara.desbloquear_camara()

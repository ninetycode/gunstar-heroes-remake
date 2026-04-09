extends CharacterBody2D

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn")
@onready var stats: Node = $StatsComponent
@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var gravity: float = 1200.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var muzzle = $AnimatedSprite2D/muzzle
@onready var shooter_time = $ShooterTime

var gravity_enabled = true

func _ready() -> void:
	stats.danio_recibido.connect(_on_danio_recibido)


func _physics_process(delta):
	# La gravedad se aplica siempre
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Movemos al personaje según lo que digan los estados
	move_and_slide()
	limitar_a_camara()

# Posiciones del muzzle por dirección (ajustá los valores a tu sprite)
# Posiciones base asumiendo ÚNICAMENTE que el personaje mira a la DERECHA
const MUZZLE_POSITIONS = {
	"recto":            Vector2(22.0, -20.0),
	"arriba":           Vector2(0.0,  -45.0),
	"abajo":            Vector2(0.0,    5.0),
	"diagonal_arriba":  Vector2(20.0, -45.0),
	"agachado":         Vector2(0.0, 0.0) # <-- Ajustá estos números en base a tu sprite agachado
}

func actualizar_animacion_apuntado(dir: Vector2):
	# 1. CASO POR DEFECTO: Si no hay dirección (Idle), dispara recto
	if dir == Vector2.ZERO:
		_animated_sprite.play("Disparo recto")
		muzzle.position = MUZZLE_POSITIONS["recto"]
		return # Cortamos acá para no procesar el resto

	# 2. VOLTEO (FLIP): Orientamos el sprite según la dirección X
	if dir.x != 0:
		_animated_sprite.flip_h = dir.x < 0

	# 3. LÓGICA VERTICAL: Determinamos si apunta arriba, abajo o neutro
	if dir.y < 0:
		# --- APUNTANDO HACIA ARRIBA ---
		if dir.x != 0:
			_animated_sprite.play("Disparo diagonal arriba")
			muzzle.position = MUZZLE_POSITIONS["diagonal_arriba"]
		else:
			_animated_sprite.play("Disparo arriba")
			muzzle.position = MUZZLE_POSITIONS["arriba"]
			
	elif dir.y > 0:
		# --- APUNTANDO HACIA ABAJO ---
		if is_on_floor():
			# Si está en el piso, se agacha
			_animated_sprite.play("Crouch")
			muzzle.position = MUZZLE_POSITIONS["agachado"]
		else:
			# Si está en el aire, usa la animación con espacio: "Disparo abajo"
			_animated_sprite.play("Disparo abajo")
			muzzle.position = MUZZLE_POSITIONS["abajo"]
			
	else:
		# --- APUNTANDO RECTO (Eje Y es 0) ---
		_animated_sprite.play("Disparo recto")
		# Ajustamos el muzzle según el flip para que no salga del hombro de atrás
		muzzle.position = MUZZLE_POSITIONS["recto"]

	# 4. FIX DE POSICIÓN PARA MIRADA A LA IZQUIERDA
	# Como tus coordenadas en el diccionario asumen mirada a la DERECHA,
	# si el sprite está flipeado, invertimos la X del muzzle.
	if _animated_sprite.flip_h:
		muzzle.position.x = -muzzle.position.x


func _input(event):
	if event.is_action_pressed("ui_focus_next"): # Tecla TAB
		# Le avisamos al componente que pase a la siguiente arma
		$WeaponComponent.rotar_arma()
		AudioManager.play_sfx("change_weapon" , -5.0, randf_range(0.9, 1.1))
	if event.is_action_released("disparo"):
		$WeaponComponent.detener_disparo()
func _on_stats_component_salud_agotada() -> void:
	print("¡Blue ha muerto!")
	# Como usamos la misma lógica, en vez de queue_free() lo "apagamos"
	#set_process(false)
	#set_physics_process(false)
	#hide()
	queue_free()
	# Acá después podés gatillar el estado de Game Over



func _on_danio_recibido(_cantidad: int) -> void:
	# Hacemos que el sprite del Player se ponga blanco brillante
	_animated_sprite.modulate = Color(10, 10, 10)
	
	# Esperamos una fracción de segundo
	await get_tree().create_timer(0.05).timeout
	
	# Lo devolvemos a su color normal
	_animated_sprite.modulate = Color(1, 1, 1)
	
func limitar_a_camara():
	var cam = get_viewport().get_camera_2d()
	if cam:
		# Calculamos el tamaño real de la pantalla según el zoom
		var screen_size = get_viewport_rect().size / cam.zoom
		var cam_pos = cam.get_screen_center_position()
		
		# Calculamos dónde están los bordes izquierdo y derecho de la pantalla
		var limite_izq = cam_pos.x - (screen_size.x / 2.0)
		var limite_der = cam_pos.x + (screen_size.x / 2.0)
		
		# Clampeamos la posición X del jugador. 
		# Le sumamos/restamos 20 píxeles para que frene justo en el borde y no quede el sprite cortado por la mitad.
		global_position.x = clamp(global_position.x, limite_izq + 20.0, limite_der - 20.0)


func _on_piramid_trigger_area_entered(_area):
	pass # Replace with function body.
	

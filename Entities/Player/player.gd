extends CharacterBody2D

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn")
@onready var stats: Node = $StatsComponent
@export var speed: float = 300.0
@export var air_speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 1200.0
@export var jump_buffer_time: float = 0.15 # 150 milisegundos de tolerancia
var jump_buffer_counter: float = 0.0
@onready var _animated_sprite = $AnimatedSprite2D
@onready var muzzle = $AnimatedSprite2D/muzzle
@onready var shooter_time = $ShooterTime
@export var en_lobby: bool = false
var gravity_enabled = true
@onready var wallet: Node = $WalletComponent
@export var max_saltos: int = 2 # 1 para salto normal, 2 para doble salto
var saltos_realizados: int = 0

func _ready() -> void:
	stats.danio_recibido.connect(_on_danio_recibido)
	
	# === 1. INYECCIÓN DE STATS (SALUD Y ESCUDO) ===
	stats.vida_maxima = 100 + (GameManager.nivel_mejora_vida * 10)
	
	if GameManager.vida_persistente != -1:
		stats.vida_actual = GameManager.vida_persistente
		stats.escudo_actual = GameManager.escudo_persistente
	else:
		stats.vida_actual = stats.vida_maxima
		stats.escudo_actual = GameManager.nivel_mejora_escudo * 20
		
	# Forzamos actualización del HUD al arrancar
	stats.health_changed.emit(stats.vida_maxima, stats.vida_actual, stats.escudo_actual)
	

	# === 2. INYECCIÓN DE BILLETERA ===
	if wallet:
		# PRIMERO conectamos el cable
		wallet.monedas_cambiadas.connect(_on_monedas_cambiadas)
		
		# SEGUNDO armamos el fajo de billetes a cargar
		var monedas_a_cargar = GameManager.monedas_totales
		
		# Si hay plata de prueba en el inspector Y todavía no la cobramos...
		if wallet.monedas_iniciales_prueba > 0 and not GameManager.plata_prueba_entregada:
			monedas_a_cargar += wallet.monedas_iniciales_prueba
			GameManager.plata_prueba_entregada = true # Marcamos que ya se entregó
			
		# TERCERO inyectamos la plata limpia a la billetera
		wallet.inicializar(monedas_a_cargar)


func _physics_process(delta):
	# 1. Actualizamos el reloj del buffer
	if jump_buffer_counter > 0.0:
		jump_buffer_counter -= delta
		
	# 2. La gravedad se aplica siempre en el aire
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# === CRÍTICO PARA EL DOBLE SALTO ===
		# Si está pisando el suelo, reseteamos el contador de saltos inmediatamente
		saltos_realizados = 0
		
	# 3. LÓGICA DE ACTIVACIÓN DEL SALTO
	# Si el buffer pide un salto Y todavía tenemos saltos disponibles...
	if jump_buffer_counter > 0.0 and saltos_realizados < max_saltos:
		ejecutar_salto()
		
	move_and_slide()
	limitar_a_camara()

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
	if event.is_action_pressed("jump"):
		jump_buffer_counter = jump_buffer_time
		
func _on_stats_component_salud_agotada() -> void:
	print("¡Blue ha muerto!")
	
	# En vez de queue_free(), le decimos a la máquina que transicione.
	# Asegurate de que el nodo del estado se llame exactamente "Death" en el editor
	$StateMachine.transition_to("Death")


func _on_monedas_cambiadas(total: int) -> void:
	GameManager.monedas_totales = total
	GameManager.monedas_globales_actualizadas.emit(total)
	
func _on_danio_recibido(_cantidad: int) -> void:
	# 1. El flash blanco del impacto inicial (Esto ya lo tenías, está perfecto)
	AudioManager.play_sfx("hit", -9.0, randf_range(0.9, 1.1))
	_animated_sprite.modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.05).timeout
	_animated_sprite.modulate = Color(1, 1, 1)
	
	# 2. El Parpadeo de Invulnerabilidad (Feedback visual)
	if stats.tiempo_invulnerabilidad > 0.0:
		# Usamos un Tween para animar el canal Alfa (transparencia) del modulate
		var tween = create_tween()
		
		# Calculamos cuántas veces tiene que parpadear en ese tiempo
		# (0.2 segundos por cada ciclo completo de ida y vuelta)
		var cantidad_parpadeos = int(stats.tiempo_invulnerabilidad / 0.2)
		
		for i in range(cantidad_parpadeos):
			# Lo hacemos semitransparente rápido
			tween.tween_property(_animated_sprite, "modulate:a", 0.3, 0.1)
			# Lo volvemos a hacer opaco
			tween.tween_property(_animated_sprite, "modulate:a", 1.0, 0.1)
			
		# Por seguridad, al final del Tween nos aseguramos que quede totalmente visible
		tween.tween_callback(func(): _animated_sprite.modulate.a = 1.0)
	
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

func ejecutar_salto():
	# Si es el primer salto, o si es el segundo salto Y la habilidad está comprada
	if saltos_realizados == 0 or (saltos_realizados == 1 and GameManager.doble_salto_desbloqueado):
		velocity.y = jump_velocity
		saltos_realizados += 1
		jump_buffer_counter = 0.0
		
		# Feedback Sonoro
		if saltos_realizados == 1:
			AudioManager.play_sfx("jump", -3.0, randf_range(0.9, 1.1))
		elif saltos_realizados == 2:
			AudioManager.play_sfx("jump", -2.0, randf_range(1.3, 1.5))
	else:
		# Si intenta hacer un doble salto pero no lo compró, vaciamos el buffer y no hace nada
		jump_buffer_counter = 0.0
	
func set_congelado(congelar: bool) -> void:
	if congelar:
		velocity = Vector2.ZERO
		if _animated_sprite:
			_animated_sprite.play("Idle")
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_INHERIT

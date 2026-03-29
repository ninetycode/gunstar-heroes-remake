extends CanvasLayer

@onready var health_label = $Label
var nombre_jefe_actual: String = ""

func _ready():
	# Forzamos la invisibilidad absoluta al arrancar
	visible = false 
	
	GameEvents.boss_fight_started.connect(_on_boss_started)
	GameEvents.boss_health_changed.connect(_on_health_changed)
	GameEvents.boss_died.connect(_on_boss_died)

func _on_boss_started(nombre_boss: String, _vida_max: int, _vida_actual: int):
	nombre_jefe_actual = nombre_boss
	
	# Cuando arranca la pelea, SOLO mostramos el nombre
	health_label.text = nombre_jefe_actual 
	visible = true 

func _on_health_changed(vida_actual: int):
	# Cuando le pegamos por primera vez, cambia para mostrar la vida restante
	# (Podés dejarlo como "HP: 1990" o sumarle el nombre "Papaya - HP: 1990")
	health_label.text = "HP: " + str(vida_actual)

func _on_boss_died():
	visible = false # Escondemos todo cuando muere

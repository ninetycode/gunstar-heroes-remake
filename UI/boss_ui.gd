extends CanvasLayer

@onready var health_label = $Label

func _ready():
	# Arranca invisible
	hide() 
	
	# Nos conectamos a los gritos del mensajero global
	GameEvents.boss_fight_started.connect(_on_boss_started)
	GameEvents.boss_health_changed.connect(_on_health_changed)
	GameEvents.boss_died.connect(_on_boss_died)

func _on_boss_started(nombre_boss: String, _vida_max: int, _vida_actual: int):
	health_label.text = nombre_boss
	show() # Hacemos visible la interfaz

func _on_health_changed(vida_actual: int):
	health_label.text =  "HP: " + str(vida_actual)

func _on_boss_died():
	hide() # Escondemos todo cuando muere

extends PanelContainer

@onready var texto_gema = $Label # El label que dice "GEMA OBTENIDA"

func _ready() -> void:
	hide()
	# Nos conectamos a la señal global que creamos en el Paso B
	GameEvents.gema_recolectada.connect(_on_gema_recolectada)

func _on_gema_recolectada(nombre: String) -> void:
	if texto_gema:
		texto_gema.text = "¡" + nombre.to_upper() + " OBTENIDA!"
		
	# Animación AAA: Aparece, se queda un ratito y hace un fade out
	show()
	modulate.a = 1.0
	
	var tween = create_tween()
	# Se queda visible 2 segundos completa
	tween.tween_interval(2.0)
	# Hace un desvanecimiento hacia 0.0 en medio segundo
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	# Se oculta por completo al terminar
	tween.tween_callback(hide)

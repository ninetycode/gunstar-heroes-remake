extends CanvasLayer

@onready var top_bar = $BarsContainer/TopBar
@onready var bottom_bar = $BarsContainer/BottomBar

func mostrar_barras(duracion: float = 0.5):
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	# Ajustá el 70 según qué tan "cine" quieras que se vea
	tween.tween_property(top_bar, "custom_minimum_size:y", 70, duracion)
	tween.tween_property(bottom_bar, "custom_minimum_size:y", 70, duracion)

func ocultar_barras(duracion: float = 0.5):
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(top_bar, "custom_minimum_size:y", 0, duracion)
	tween.tween_property(bottom_bar, "custom_minimum_size:y", 0, duracion)

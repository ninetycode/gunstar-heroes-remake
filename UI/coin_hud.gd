extends CanvasLayer

@onready var coin_label = %CoinLabel
@onready var coin_container = %CoinContainer
@export var visible_al_arrancar: bool = false 

var tween_coin: Tween

func _ready():
	if visible_al_arrancar:
		coin_container.modulate.a = 1.0
	else:
		coin_container.modulate.a = 0.0 
	
	_actualizar_interfaz(GameManager.monedas_totales) 
	GameManager.monedas_globales_actualizadas.connect(_actualizar_interfaz) 
	
	var player = get_tree().get_first_node_in_group("Player") 
	if player:
		# --- EL FIX ESTÁ ACÁ ---
		# Buscamos el WalletComponent en vez del StatsComponent
		var wallet = player.get_node_or_null("WalletComponent") 
		if wallet:
			wallet.monedas_cambiadas.connect(_on_player_monedas_cambiadas) 

func _actualizar_interfaz(total: int):
	if coin_label:
		coin_label.text = str(total)

func _on_player_monedas_cambiadas(total: int):
	_actualizar_interfaz(total)
	
	if tween_coin and tween_coin.is_valid():
		tween_coin.kill()
		
	tween_coin = create_tween()
	tween_coin.tween_property(coin_container, "modulate:a", 1.0, 0.3)
	tween_coin.tween_interval(2.0)
	tween_coin.tween_property(coin_container, "modulate:a", 0.0, 0.5)

func forzar_visibilidad(visible_si: bool):
	if tween_coin and tween_coin.is_valid():
		tween_coin.kill()
	coin_container.modulate.a = 1.0 if visible_si else 0.0

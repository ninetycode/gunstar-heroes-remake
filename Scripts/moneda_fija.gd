extends BaseItem # <-- HEREDA DE TU BASEITEM OFICIAL
class_name MonedaFija

## ID Único para esta moneda en todo el juego (Ej: "tut_m1")
@export var id_unica: String = ""
@export var valor_moneda: int = 1

func _ready() -> void:
	# 1. Ejecutamos el _ready del BaseItem para que se conecten las colisiones y el grupo
	super()
	
	# 2. Si te olvidaste de ponerle ID en el inspector, se genera una automática
	if id_unica == "":
		id_unica = get_tree().current_scene.name + "_" + name
		
	# === FILTRO DE PERSISTENCIA ===
	# Si el GameManager dice que esta ID ya se juntó, la hacemos desaparecer antes de que se vea
	if GameManager.objetos_fijos_agarrados.has(id_unica):
		queue_free()

# Sobrescribimos la función virtual que tu BaseItem llama al detectar al Player
func aplicar_efecto(player: Node2D) -> bool:
	var wallet = player.get_node_or_null("WalletComponent")
	
	if wallet and wallet.has_method("agregar_monedas"):
		# === REGISTRO INMORTAL ===
		# Guardamos en el diccionario global que ESTA moneda específica ya fue tomada
		GameManager.objetos_fijos_agarrados[id_unica] = true
		
		# === COBRO EFECTIVO ===
		# Usamos tu método oficial del componente wallet
		wallet.agregar_monedas(valor_moneda)
		
		# Feedback sonoro
		AudioManager.play_sfx("coin")
		
		return true # Devolvemos true para que BaseItem ejecute el queue_free()
		
	return false

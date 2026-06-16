extends Node
class_name WalletComponent

signal monedas_cambiadas(total_monedas)

@export_category("Debug y Pruebas")
## Monedas extra que se le darán a Blue solo para testeos desde el Inspector.
@export var monedas_iniciales_prueba: int = 0

var monedas_actuales: int = 0

func inicializar(cantidad_inicial: int) -> void:
	monedas_actuales = cantidad_inicial
	monedas_cambiadas.emit(monedas_actuales)

func agregar_monedas(cantidad: int) -> void:
	monedas_actuales += cantidad
	monedas_cambiadas.emit(monedas_actuales)

func gastar_monedas(cantidad: int) -> bool:
	if monedas_actuales >= cantidad:
		monedas_actuales -= cantidad
		monedas_cambiadas.emit(monedas_actuales)
		return true
	return false

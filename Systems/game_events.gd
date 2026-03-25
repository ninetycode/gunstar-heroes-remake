extends Node

# Señales globales que cualquier script puede escuchar
signal boss_fight_started(nombre_boss: String, vida_max: int, vida_actual: int)
signal boss_health_changed(vida_actual: int)
signal boss_died()

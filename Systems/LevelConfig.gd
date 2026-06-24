extends Resource
class_name LevelConfig

@export_category("Datos del Menú")
@export var nombre_nivel: String = "Nivel Desconocido"
@export var miniatura: Texture2D

@export_category("Diseño del Nivel")
@export var pool_habitaciones: Array[String] # Las escenas de Facu para este nivel
@export var jefe_final: String               # La escena del boss de este nivel
@export var cantidad_salas: int = 8          # Cuántas salas antes del jefe
@export_category("Finalización")
@export var es_nivel_final: bool = false


@export_category("Música del Nivel")
@export var musica_ambiente: String = ""
@export var musica_jefe: String = ""

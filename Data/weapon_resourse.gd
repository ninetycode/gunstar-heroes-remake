extends Resource
class_name WeaponResource

enum WeaponType { NORMAL, FIRE, HOMING }

@export var weapon_type : WeaponType = WeaponType.NORMAL
@export var bullet_scene : PackedScene 
@export var textura_bala : Texture2D # 
@export var bullet_textures : Array[Texture2D] # 
@export var danio : int = 10         # 
@export var velocidad_bala : float = 400.0 # <-- Volvemos al original
@export var fire_rate : float = 0.2  # <-- Volvemos al original que busca weapon_component
@export var escala_bala : Vector2 = Vector2(1, 1) # <-- Faltaba agregarla según tu imagen

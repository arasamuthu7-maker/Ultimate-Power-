extends Node3D

@export var enemy_scene: PackedScene = preload("res://Enemy.tscn")
@export var spawn_position: Vector3 = Vector3(0, 0.9, -6)
@export var respawn_delay: float = 3.0

var enemy_instance: Node3D
var respawn_pending: bool = false

func _ready() -> void:
    spawn_enemy()

func spawn_enemy() -> void:
    if not is_instance_valid(enemy_scene):
        return
    enemy_instance = enemy_scene.instantiate() as Node3D
    if enemy_instance == null:
        return
    enemy_instance.position = spawn_position
    add_child(enemy_instance)
    if enemy_instance.has_signal("defeated"):
        enemy_instance.defeated.connect(_on_enemy_defeated)

func _on_enemy_defeated() -> void:
    if respawn_pending:
        return
    respawn_pending = true
    await get_tree().create_timer(respawn_delay).timeout
    respawn_pending = false
    if is_inside_tree():
        spawn_enemy()

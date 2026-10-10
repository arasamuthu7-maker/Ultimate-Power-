extends Node3D
@export var boss_scene: PackedScene = preload("res://Boss.tscn")
@export var spawn_position: Vector3 = Vector3(0, 0.9, -24)
var spawned := false

func _ready() -> void:
    var timer := get_tree().create_timer(12.0)
    timer.timeout.connect(_spawn_boss)

func _spawn_boss() -> void:
    if spawned or not is_inside_tree(): return
    var boss := boss_scene.instantiate() as Node3D
    if boss == null: return
    boss.position = spawn_position
    add_child(boss)
    spawned = true
    if boss.has_signal("defeated"):
        boss.defeated.connect(_on_boss_defeated)

func _on_boss_defeated() -> void:
    spawned = false
    print("VOID BOSS DEFEATED! The island is safe.")
    await get_tree().create_timer(20.0).timeout
    if is_inside_tree(): _spawn_boss()

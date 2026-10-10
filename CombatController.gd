extends Node

@export var player_path: NodePath = NodePath("../Player")

var player: CharacterBody3D
var power_system: Node

func _ready() -> void:
    player = get_node_or_null(player_path) as CharacterBody3D
    power_system = preload("res://PowerSystem.gd").new()
    add_child(power_system)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_1:
                use_power("Energy Blast")
            KEY_2:
                use_power("Ground Smash")
            KEY_3:
                use_power("Power Dash")

func use_power(power_name: String) -> void:
    if not is_instance_valid(player) or not power_system.use_power(power_name):
        return

    var info: Dictionary = power_system.get_power_info(power_name)
    var radius := float(info.get("range", 0.0))
    var damage := float(info.get("damage", 0.0))
    var enemies := get_tree().get_nodes_in_group("enemies")
    var nearest: Node3D
    var nearest_distance := INF

    for node in enemies:
        if not is_instance_valid(node) or not node is Node3D:
            continue
        var enemy := node as Node3D
        var distance := player.global_position.distance_to(enemy.global_position)
        if distance <= radius:
            if damage > 0.0 and enemy.has_method("take_damage"):
                enemy.take_damage(damage)
            if distance < nearest_distance:
                nearest_distance = distance
                nearest = enemy

    if power_name == "Power Dash" and is_instance_valid(nearest):
        var direction := nearest.global_position - player.global_position
        direction.y = 0.0
        if direction.length() > 0.1:
            player.global_position += direction.normalized() * minf(radius, direction.length())

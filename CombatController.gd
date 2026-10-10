extends Node

@export var player_path: NodePath = NodePath("../Player")

var player: CharacterBody3D
var power_system: Node
var effects_root: Node3D

func _ready() -> void:
    player = get_node_or_null(player_path) as CharacterBody3D
    power_system = preload("res://PowerSystem.gd").new()
    add_child(power_system)
    effects_root = Node3D.new()
    effects_root.name = "PowerEffects"
    get_tree().current_scene.add_child(effects_root)

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
    if has_node("/root/GameProgress"):
        damage += float(get_node("/root/GameProgress").attack_bonus)
    _spawn_power_effect(power_name, radius)
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

func _spawn_power_effect(power_name: String, radius: float) -> void:
    if not is_instance_valid(effects_root) or not is_instance_valid(player):
        return
    var mesh_instance := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.35
    sphere.height = 0.7
    mesh_instance.mesh = sphere
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    if power_name == "Ground Smash":
        material.albedo_color = Color(1.0, 0.45, 0.08, 0.75)
        mesh_instance.position = player.global_position + Vector3(0, 0.15, 0)
        mesh_instance.scale = Vector3(0.5, 0.08, 0.5)
    elif power_name == "Power Dash":
        material.albedo_color = Color(0.1, 0.8, 1.0, 0.8)
        mesh_instance.position = player.global_position + Vector3(0, 1.0, 0)
        mesh_instance.scale = Vector3(0.5, 0.5, 0.5)
    else:
        material.albedo_color = Color(0.1, 0.65, 1.0, 0.85)
        mesh_instance.position = player.global_position + (-player.global_basis.z * 1.5) + Vector3(0, 1.0, 0)
        mesh_instance.scale = Vector3(0.6, 0.6, 0.6)
    mesh_instance.material_override = material
    effects_root.add_child(mesh_instance)
    var tween := create_tween()
    tween.tween_property(mesh_instance, "scale", Vector3.ONE * maxf(1.0, minf(radius * 0.18, 3.0)), 0.22)
    tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.28)
    tween.tween_callback(mesh_instance.queue_free)

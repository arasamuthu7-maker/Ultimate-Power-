extends Node3D

@export var max_health: float = 100.0
@export var bar_width: float = 2.0
@export var bar_height: float = 0.18

var current_health: float = 100.0
var fill_mesh: MeshInstance3D
var fill_box: BoxMesh
var fill_material: StandardMaterial3D

func _ready() -> void:
    current_health = max_health
    var background := MeshInstance3D.new()
    var background_mesh := BoxMesh.new()
    background_mesh.size = Vector3(bar_width, bar_height, 0.06)
    background.mesh = background_mesh
    var background_material := StandardMaterial3D.new()
    background_material.albedo_color = Color(0.12, 0.12, 0.12, 1.0)
    background.material_override = background_material
    add_child(background)

    fill_mesh = MeshInstance3D.new()
    fill_box = BoxMesh.new()
    fill_box.size = Vector3(bar_width, bar_height, 0.07)
    fill_mesh.mesh = fill_box
    fill_material = StandardMaterial3D.new()
    fill_material.albedo_color = Color(0.15, 0.9, 0.2, 1.0)
    fill_mesh.material_override = fill_material
    fill_mesh.position.z = -0.04
    add_child(fill_mesh)
    _refresh()

func set_health(value: float, maximum: float = -1.0) -> void:
    if maximum > 0.0:
        max_health = maximum
    current_health = clampf(value, 0.0, max_health)
    _refresh()

func _refresh() -> void:
    if not is_instance_valid(fill_mesh) or not is_instance_valid(fill_box):
        return
    var ratio := 0.0 if max_health <= 0.0 else current_health / max_health
    fill_box.size.x = bar_width * ratio
    fill_mesh.position.x = -(bar_width - fill_box.size.x) * 0.5
    if is_instance_valid(fill_material):
        if ratio > 0.5:
            fill_material.albedo_color = Color(0.15, 0.9, 0.2, 1.0)
        elif ratio > 0.25:
            fill_material.albedo_color = Color(1.0, 0.7, 0.1, 1.0)
        else:
            fill_material.albedo_color = Color(0.95, 0.15, 0.12, 1.0)

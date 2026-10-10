extends Node3D
## A second floating island connected by a simple raised bridge.
func _ready() -> void:
    _block("IslandBase", Vector3(24, 0.8, 18), Vector3(0, -0.5, -27), Color(0.22, 0.38, 0.25))
    _block("IslandShrine", Vector3(5, 1.0, 4), Vector3(0, 0.1, -27), Color(0.28, 0.3, 0.75))
    _block("Bridge", Vector3(5, 0.35, 13), Vector3(0, -0.05, -15.5), Color(0.38, 0.36, 0.32))
    for side in [-1.0, 1.0]:
        _block("Crystal", Vector3(0.7, 2.2, 0.7), Vector3(side * 7.0, 0.65, -27), Color(0.18, 0.75, 1.0))
        _block("IslandRock", Vector3(2.5, 1.5, 2.0), Vector3(side * 9.0, 0.1, -31), Color(0.23, 0.24, 0.28))

func _block(label: String, size: Vector3, pos: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = label
    body.position = pos
    var mesh_node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_node.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    mesh_node.material_override = material
    body.add_child(mesh_node)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

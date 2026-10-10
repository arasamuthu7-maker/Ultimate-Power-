extends Node3D
## Procedural original character visuals; no third-party character assets required.
@export_enum("hero", "enemy") var character_style: String = "hero"

func _ready() -> void:
    _build_character()

func _mat(color: Color, emission: Color = Color.BLACK) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    if emission != Color.BLACK:
        m.emission_enabled = true
        m.emission = emission
        m.emission_energy_multiplier = 1.4
    return m

func _part(parent: Node3D, mesh: Mesh, pos: Vector3, material: Material, part_name: String) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    node.mesh = mesh
    node.position = pos
    node.material_override = material
    parent.add_child(node)
    return node

func _box(size: Vector3) -> BoxMesh:
    var m := BoxMesh.new()
    m.size = size
    return m

func _capsule(radius: float, height: float) -> CapsuleMesh:
    var m := CapsuleMesh.new()
    m.radius = radius
    m.height = height
    return m

func _sphere(radius: float) -> SphereMesh:
    var m := SphereMesh.new()
    m.radius = radius
    m.height = radius * 2.0
    return m

func _build_character() -> void:
    var hero := character_style == "hero"
    var dark := _mat(Color(0.045, 0.065, 0.11))
    var trim := _mat(Color(0.05, 0.65, 1.0), Color(0.02, 0.35, 1.0)) if hero else _mat(Color(0.42, 0.12, 0.8), Color(0.45, 0.04, 1.0))
    var skin := _mat(Color(0.78, 0.58, 0.46)) if hero else _mat(Color(0.12, 0.08, 0.19))
    var hair := _mat(Color(0.12, 0.14, 0.2)) if hero else _mat(Color(0.08, 0.04, 0.14))
    var coat := _mat(Color(0.025, 0.035, 0.07)) if hero else _mat(Color(0.09, 0.055, 0.16))
    var metal := _mat(Color(0.18, 0.21, 0.3)) if hero else _mat(Color(0.19, 0.12, 0.29))
    _part(self, _capsule(0.28, 0.82), Vector3(0, 1.05, 0), coat, "CoatTorso")
    _part(self, _box(Vector3(0.56, 0.62, 0.12)), Vector3(0, 1.08, -0.19), dark, "ChestArmor")
    _part(self, _box(Vector3(0.38, 0.08, 0.04)), Vector3(0, 1.22, -0.26), trim, "EnergyEmblem")
    for side in [-1.0, 1.0]:
        _part(self, _capsule(0.105, 0.72), Vector3(side * 0.37, 1.08, 0), metal, "Arm")
        _part(self, _sphere(0.14), Vector3(side * 0.39, 0.69, -0.02), trim, "EnergyGauntlet")
        _part(self, _capsule(0.12, 0.7), Vector3(side * 0.15, 0.38, 0), dark, "Leg")
        _part(self, _box(Vector3(0.24, 0.13, 0.36)), Vector3(side * 0.15, 0.07, -0.06), metal, "Boot")
    _part(self, _capsule(0.22, 0.28), Vector3(0, 1.62, 0), skin, "Neck")
    _part(self, _sphere(0.29), Vector3(0, 1.88, 0), skin, "Head")
    _part(self, _sphere(0.3), Vector3(0, 2.02, 0.015), hair, "Hair")
    for side in [-1.0, 1.0]:
        _part(self, _sphere(0.055), Vector3(side * 0.12, 1.9, -0.255), trim, "EyeGlow")
        spike := _part(self, _box(Vector3(0.13, 0.32, 0.14)), Vector3(side * 0.15, 2.16, -0.015), hair, "HairSpike")
        spike.rotation.z = side * -0.45
    _part(self, _box(Vector3(0.42, 0.46, 0.09)), Vector3(0, 0.92, 0.2), coat, "BackCoat")
    if not hero:
        _part(self, _box(Vector3(0.13, 0.8, 0.12)), Vector3(0.48, 1.02, 0.03), trim, "VoidBlade")
        _part(self, _sphere(0.19), Vector3(0, 1.12, -0.28), trim, "VoidCore")

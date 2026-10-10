extends CharacterBody3D

@export var move_speed: float = 6.0

var gravity: float = 9.8

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    var input_dir = Input.get_vector(
        "ui_left", "ui_right",
        "ui_up", "ui_down"
    )

    var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

    velocity.x = direction.x * move_speed
    velocity.z = direction.z * move_speed

    move_and_slide()

extends CharacterBody3D

@export var move_speed: float = 6.0

var gravity: float = 9.8
var mobile_move_input: Vector2 = Vector2.ZERO
var mobile_jump_requested: bool = false
@export var jump_velocity: float = 7.0

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("ui_accept") or mobile_jump_requested:
        velocity.y = jump_velocity
    mobile_jump_requested = false

    var input_dir = Input.get_vector(
        "ui_left", "ui_right",
        "ui_up", "ui_down"
    )
    if mobile_move_input.length() > 0.05:
        input_dir = mobile_move_input

    var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

    velocity.x = direction.x * move_speed
    velocity.z = direction.z * move_speed

    move_and_slide()

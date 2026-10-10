extends Control

@export var joystick_radius: float = 76.0
@export var knob_radius: float = 32.0

var input_vector: Vector2 = Vector2.ZERO
var touch_active: bool = false
var active_touch_index: int = -1
var player: Node

func _ready() -> void:
    custom_minimum_size = Vector2(190, 190)
    mouse_filter = Control.MOUSE_FILTER_STOP
    player = get_tree().current_scene.get_node_or_null("Player")
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and not touch_active:
            touch_active = true
            active_touch_index = event.index
            _update_stick(event.position)
            accept_event()
        elif not event.pressed and event.index == active_touch_index:
            _release_stick()
            accept_event()
    elif event is InputEventScreenDrag and touch_active and event.index == active_touch_index:
        _update_stick(event.position)
        accept_event()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            touch_active = true
            _update_stick(event.position)
        else:
            _release_stick()
        accept_event()
    elif event is InputEventMouseMotion and touch_active:
        _update_stick(event.position)
        accept_event()

func _update_stick(local_position: Vector2) -> void:
    var center := size * 0.5
    var offset := local_position - center
    if offset.length() > joystick_radius:
        offset = offset.normalized() * joystick_radius
    input_vector = Vector2(offset.x / joystick_radius, offset.y / joystick_radius)
    if is_instance_valid(player):
        player.set("mobile_move_input", input_vector)
    queue_redraw()

func _release_stick() -> void:
    touch_active = false
    active_touch_index = -1
    input_vector = Vector2.ZERO
    if is_instance_valid(player):
        player.set("mobile_move_input", Vector2.ZERO)
    queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    draw_circle(center, joystick_radius, Color(0.05, 0.08, 0.14, 0.52))
    draw_arc(center, joystick_radius, 0.0, TAU, 64, Color(0.7, 0.85, 1.0, 0.7), 3.0, true)
    draw_circle(center + input_vector * joystick_radius, knob_radius, Color(0.25, 0.65, 1.0, 0.88))
    draw_arc(center + input_vector * joystick_radius, knob_radius, 0.0, TAU, 48, Color(0.9, 0.97, 1.0, 0.95), 2.0, true)

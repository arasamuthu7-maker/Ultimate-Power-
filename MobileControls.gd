extends CanvasLayer

@onready var player: CharacterBody3D = get_parent().get_node("Player")

func _ready() -> void:
    _bind_button("Left", "touch_left")
    _bind_button("Right", "touch_right")
    _bind_button("Forward", "touch_forward")
    _bind_button("Back", "touch_back")

func _bind_button(button_name: String, flag_name: String) -> void:
    var button: Button = get_node(button_name)
    button.button_down.connect(_set_flag.bind(flag_name, true))
    button.button_up.connect(_set_flag.bind(flag_name, false))

func _set_flag(flag_name: String, pressed: bool) -> void:
    player.set(flag_name, pressed)

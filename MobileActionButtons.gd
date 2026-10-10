extends Control

var player: CharacterBody3D
var combat: Node

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    player = get_tree().current_scene.get_node_or_null("Player") as CharacterBody3D
    combat = get_tree().current_scene.get_node_or_null("CombatController")
    _make_button("JUMP", Vector2(-170, -205), Vector2(76, 76), _jump)
    _make_button("BLAST", Vector2(-265, -115), Vector2(82, 62), _blast)
    _make_button("SMASH", Vector2(-170, -115), Vector2(82, 62), _smash)
    _make_button("DASH", Vector2(-75, -115), Vector2(68, 62), _dash)

func _make_button(label_text: String, bottom_right_offset: Vector2, button_size: Vector2, action: Callable) -> void:
    var button := Button.new()
    button.text = label_text
    button.size = button_size
    button.position = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y) + bottom_right_offset
    button.add_theme_font_size_override("font_size", 15)
    button.add_theme_color_override("font_color", Color.WHITE)
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_stylebox_override("normal", _button_style(Color(0.08, 0.25, 0.48, 0.88)))
    button.add_theme_stylebox_override("hover", _button_style(Color(0.12, 0.42, 0.72, 0.96)))
    button.add_theme_stylebox_override("pressed", _button_style(Color(0.2, 0.58, 0.9, 1.0)))
    button.pressed.connect(action)
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(button)

func _button_style(color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.corner_radius_top_left = 32
    style.corner_radius_top_right = 32
    style.corner_radius_bottom_left = 32
    style.corner_radius_bottom_right = 32
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.border_color = Color(0.55, 0.82, 1.0, 0.95)
    return style

func _jump() -> void:
    if is_instance_valid(player):
        player.set("mobile_jump_requested", true)

func _blast() -> void:
    if is_instance_valid(combat) and combat.has_method("use_power"):
        combat.use_power("Energy Blast")

func _smash() -> void:
    if is_instance_valid(combat) and combat.has_method("use_power"):
        combat.use_power("Ground Smash")

func _dash() -> void:
    if is_instance_valid(combat) and combat.has_method("use_power"):
        combat.use_power("Power Dash")

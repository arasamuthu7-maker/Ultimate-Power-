extends Control

@export var load_duration: float = 1.8

var progress_bar: ProgressBar
var status_label: Label
var progress_value: float = 0.0
var loading_done: bool = false
var address_input: LineEdit
var network_status: Label
var enter_button: Button
var _waiting_for_join: bool = false

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_ui()
    _animate_loading()
    MultiplayerManager.connection_status_changed.connect(_on_network_status)

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color(0.025, 0.035, 0.08, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var center := VBoxContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    center.position = Vector2(-300, -260)
    center.size = Vector2(600, 520)
    center.alignment = BoxContainer.ALIGNMENT_CENTER
    center.add_theme_constant_override("separation", 10)
    add_child(center)

    var title := Label.new()
    title.text = "ULTIMATE POWER"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 38)
    title.add_theme_color_override("font_color", Color(0.3, 0.75, 1.0))
    center.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "SIMULATOR"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 23)
    subtitle.add_theme_color_override("font_color", Color(1.0, 0.78, 0.22))
    center.add_child(subtitle)

    status_label = Label.new()
    status_label.text = "Preparing your world..."
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center.add_child(status_label)

    progress_bar = ProgressBar.new()
    progress_bar.min_value = 0
    progress_bar.max_value = 100
    progress_bar.custom_minimum_size = Vector2(480, 24)
    center.add_child(progress_bar)

    var network_title := Label.new()
    network_title.text = "PLAY WITH FRIENDS (ONLINE)"
    network_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    network_title.add_theme_font_size_override("font_size", 19)
    network_title.add_theme_color_override("font_color", Color(0.35, 0.85, 1.0))
    center.add_child(network_title)

    address_input = LineEdit.new()
    address_input.placeholder_text = "Host public IP / hostname (for Join)"
    address_input.custom_minimum_size = Vector2(400, 42)
    center.add_child(address_input)

    var network_buttons := HBoxContainer.new()
    network_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    network_buttons.add_theme_constant_override("separation", 12)
    center.add_child(network_buttons)

    var host_button := Button.new()
    host_button.text = "HOST GAME"
    host_button.custom_minimum_size = Vector2(180, 48)
    host_button.pressed.connect(_on_host_pressed)
    network_buttons.add_child(host_button)

    var join_button := Button.new()
    join_button.text = "JOIN FRIEND"
    join_button.custom_minimum_size = Vector2(180, 48)
    join_button.pressed.connect(_on_join_pressed)
    network_buttons.add_child(join_button)

    network_status = Label.new()
    network_status.text = "Direct online play needs a reachable host and UDP port 24560."
    network_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    network_status.custom_minimum_size = Vector2(500, 48)
    network_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center.add_child(network_status)

    enter_button = Button.new()
    enter_button.text = "ENTER SOLO WORLD"
    enter_button.custom_minimum_size = Vector2(240, 48)
    enter_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    enter_button.disabled = true
    enter_button.pressed.connect(_on_solo_pressed)
    center.add_child(enter_button)

    var footer := Label.new()
    footer.text = "TRAIN • UNLOCK POWERS • EXPLORE WITH FRIENDS"
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    footer.position.y = -30
    footer.add_theme_color_override("font_color", Color(0.65, 0.7, 0.82))
    add_child(footer)

func _animate_loading() -> void:
    var tween := create_tween()
    tween.tween_method(_set_progress, 0.0, 100.0, maxf(load_duration, 0.2))
    tween.finished.connect(_finish_loading)

func _set_progress(value: float) -> void:
    progress_value = value
    if is_instance_valid(progress_bar):
        progress_bar.value = value
    if is_instance_valid(status_label):
        if value < 35:
            status_label.text = "Charging power cores..."
        elif value < 70:
            status_label.text = "Preparing the training world..."
        else:
            status_label.text = "Almost ready..."

func _finish_loading() -> void:
    loading_done = true
    if is_instance_valid(status_label):
        status_label.text = "World ready. Are you ready, hero?"
    if is_instance_valid(enter_button):
        enter_button.disabled = false

func _on_network_status(message: String) -> void:
    if is_instance_valid(network_status):
        network_status.text = message
    if _waiting_for_join and message.begins_with("Connected!"):
        _waiting_for_join = false
        get_tree().change_scene_to_file("res://Main.tscn")

func _on_host_pressed() -> void:
    var result: Error = MultiplayerManager.host_game()
    if result == OK:
        get_tree().change_scene_to_file("res://Main.tscn")

func _on_join_pressed() -> void:
    _waiting_for_join = true
    var result: Error = MultiplayerManager.join_game(address_input.text)
    if result != OK:
        _waiting_for_join = false
        network_status.text = MultiplayerManager.status_text

func _on_solo_pressed() -> void:
    MultiplayerManager.disconnect_session()
    get_tree().change_scene_to_file("res://Main.tscn")

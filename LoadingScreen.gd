extends Control

signal loading_finished

@export var load_duration: float = 1.8

var progress_bar: ProgressBar
var status_label: Label
var start_button: Button
var progress_value: float = 0.0
var loading_done: bool = false

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_ui()
    _animate_loading()

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color(0.025, 0.035, 0.08, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var center := VBoxContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    center.position = Vector2(-280, -150)
    center.size = Vector2(560, 300)
    center.alignment = BoxContainer.ALIGNMENT_CENTER
    center.add_theme_constant_override("separation", 18)
    add_child(center)

    var title := Label.new()
    title.text = "ULTIMATE POWER"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 42)
    title.add_theme_color_override("font_color", Color(0.3, 0.75, 1.0))
    center.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "SIMULATOR"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 25)
    subtitle.add_theme_color_override("font_color", Color(1.0, 0.78, 0.22))
    center.add_child(subtitle)

    var spacer := Control.new()
    spacer.custom_minimum_size.y = 20
    center.add_child(spacer)

    status_label = Label.new()
    status_label.text = "Preparing your world..."
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center.add_child(status_label)

    progress_bar = ProgressBar.new()
    progress_bar.min_value = 0
    progress_bar.max_value = 100
    progress_bar.value = 0
    progress_bar.show_percentage = true
    progress_bar.custom_minimum_size = Vector2(500, 28)
    center.add_child(progress_bar)

    start_button = Button.new()
    start_button.text = "ENTER WORLD"
    start_button.custom_minimum_size = Vector2(240, 54)
    start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    start_button.disabled = true
    start_button.pressed.connect(_on_start_pressed)
    center.add_child(start_button)

    var footer := Label.new()
    footer.text = "TRAIN • UNLOCK POWERS • BECOME LEGENDARY"
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    footer.position.y = -44
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
    if is_instance_valid(start_button):
        start_button.disabled = false

func _on_start_pressed() -> void:
    if loading_done:
        loading_finished.emit()
        get_tree().change_scene_to_file("res://Main.tscn")

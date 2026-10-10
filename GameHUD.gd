extends CanvasLayer

@export var player_health_path: NodePath = NodePath("../Player/Health")

var health_component: Node
var health_label: Label
var health_bar: ProgressBar
var status_label: Label
var progress_label: Label

func _ready() -> void:
    health_component = get_node_or_null(player_health_path)
    var panel := PanelContainer.new()
    panel.position = Vector2(18, 18)
    panel.custom_minimum_size = Vector2(240, 86)
    add_child(panel)

    var layout := VBoxContainer.new()
    panel.add_child(layout)

    health_label = Label.new()
    health_label.text = "PLAYER HP: 100 / 100"
    layout.add_child(health_label)

    health_bar = ProgressBar.new()
    health_bar.min_value = 0.0
    health_bar.max_value = 100.0
    health_bar.value = 100.0
    health_bar.show_percentage = false
    health_bar.custom_minimum_size = Vector2(220, 18)
    layout.add_child(health_bar)

    status_label = Label.new()
    status_label.text = "BLAST  |  SMASH  |  DASH"
    status_label.position = Vector2(18, 112)
    add_child(status_label)

    progress_label = Label.new()
    progress_label.position = Vector2(18, 142)
    add_child(progress_label)
    if has_node("/root/GameProgress"):
        get_node("/root/GameProgress").progress_changed.connect(_on_progress_changed)
        _on_progress_changed(get_node("/root/GameProgress").level, get_node("/root/GameProgress").xp, get_node("/root/GameProgress").coins)

    if is_instance_valid(health_component):
        health_component.health_changed.connect(_on_health_changed)
        health_component.defeated.connect(_on_player_defeated)
        _on_health_changed(health_component.current_health, health_component.max_health)

func _on_health_changed(current: float, maximum: float) -> void:
    if is_instance_valid(health_bar):
        health_bar.max_value = maximum
        health_bar.value = current
    if is_instance_valid(health_label):
        health_label.text = "PLAYER HP: %d / %d" % [roundi(current), roundi(maximum)]

func _on_player_defeated() -> void:
    if is_instance_valid(status_label):
        status_label.text = "KNOCKED OUT — restart the scene to try again"


func _on_progress_changed(level: int, xp: int, coins: int) -> void:
    if is_instance_valid(progress_label):
        progress_label.text = "LEVEL %d  |  XP %d/%d  |  COINS %d" % [level, xp, level * 100, coins]

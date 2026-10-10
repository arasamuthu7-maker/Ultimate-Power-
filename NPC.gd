extends CharacterBody3D

@export var npc_name: String = "Villager"
@export_enum("Quest", "Shop", "Trainer") var npc_role: String = "Quest"
@export_multiline var dialogue: String = "Hello, traveler!"
@export var interact_distance: float = 3.0

var player: Node3D
var prompt_label: Label3D
var gravity: float = 9.8
var dialogue_panel: PanelContainer
var dialogue_text: Label
var dialogue_title: Label
var dialogue_close: Button
var _last_spoken: String = ""

func _ready() -> void:
    add_to_group("npcs")
    player = get_tree().current_scene.get_node_or_null("Player") as Node3D
    _build_dialogue_ui()

    prompt_label = Label3D.new()
    prompt_label.text = "Press E / TALK"
    prompt_label.font_size = 48
    prompt_label.position = Vector3(0, 2.25, 0)
    prompt_label.pixel_size = 0.005
    prompt_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(prompt_label)
    _refresh_prompt()

func _build_dialogue_ui() -> void:
    var layer := CanvasLayer.new()
    layer.name = "NPCDialogueLayer"
    layer.layer = 20
    get_tree().current_scene.add_child.call_deferred(layer)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.name = "DialoguePanel"
    dialogue_panel.anchor_left = 0.08
    dialogue_panel.anchor_right = 0.92
    dialogue_panel.anchor_top = 0.68
    dialogue_panel.anchor_bottom = 0.94
    dialogue_panel.offset_left = 0
    dialogue_panel.offset_right = 0
    dialogue_panel.offset_top = 0
    dialogue_panel.offset_bottom = 0
    dialogue_panel.visible = false
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.025, 0.045, 0.10, 0.96)
    style.border_color = Color(0.25, 0.72, 1.0, 1.0)
    style.set_border_width_all(2)
    style.set_corner_radius_all(14)
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    dialogue_panel.add_theme_stylebox_override("panel", style)
    layer.add_child(dialogue_panel)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 6)
    dialogue_panel.add_child(layout)

    dialogue_title = Label.new()
    dialogue_title.add_theme_font_size_override("font_size", 22)
    dialogue_title.add_theme_color_override("font_color", Color(0.45, 0.82, 1.0))
    layout.add_child(dialogue_title)

    dialogue_text = Label.new()
    dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_text.add_theme_font_size_override("font_size", 18)
    dialogue_text.add_theme_color_override("font_color", Color.WHITE)
    dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(dialogue_text)

    dialogue_close = Button.new()
    dialogue_close.text = "CLOSE"
    dialogue_close.custom_minimum_size.y = 42
    dialogue_close.pressed.connect(_close_dialogue)
    layout.add_child(dialogue_close)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0
    velocity.x = 0.0
    velocity.z = 0.0
    move_and_slide()
    _refresh_prompt()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
        if _player_is_near():
            _interact()

func _player_is_near() -> bool:
    return is_instance_valid(player) and global_position.distance_to(player.global_position) <= interact_distance

func _refresh_prompt() -> void:
    if not is_instance_valid(prompt_label):
        return
    prompt_label.visible = _player_is_near()
    if not _player_is_near() and is_instance_valid(dialogue_panel):
        dialogue_panel.visible = false
        if DisplayServer.tts_is_speaking():
            DisplayServer.tts_stop()

func interact_from_mobile() -> void:
    if _player_is_near():
        _interact()

func _interact() -> void:
    var message := dialogue
    if has_node("/root/GameProgress"):
        var progress := get_node("/root/GameProgress")
        match npc_role:
            "Quest":
                message = progress.quest_status() + " — defeat enemies to earn XP and coins."
            "Shop":
                if progress.buy_attack_upgrade():
                    message = "Upgrade purchased! Your powers deal +5 damage. Coins left: %d" % progress.coins
                else:
                    message = "Attack upgrade costs 50 coins. You have %d." % progress.coins
            "Trainer":
                message = "Training: use BLAST, SMASH and DASH. Current Level: %d" % progress.level

    _last_spoken = message
    dialogue_title.text = npc_name
    dialogue_text.text = message
    dialogue_panel.visible = true
    _speak_dialogue(message)

func _speak_dialogue(message: String) -> void:
    var voices: Array = DisplayServer.tts_get_voices()
    if voices.is_empty():
        return
    var voice_id: String = str(voices[0].get("id", ""))
    if not voice_id.is_empty():
        DisplayServer.tts_stop()
        DisplayServer.tts_speak(message, voice_id, 1.0, 1.0, 1.0)

func _close_dialogue() -> void:
    dialogue_panel.visible = false
    if DisplayServer.tts_is_speaking():
        DisplayServer.tts_stop()

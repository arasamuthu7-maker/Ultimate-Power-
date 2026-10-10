extends CharacterBody3D

@export var npc_name: String = "Villager"
@export_enum("Quest", "Shop", "Trainer") var npc_role: String = "Quest"
@export_multiline var dialogue: String = "Hello, traveler!"
@export var interact_distance: float = 3.0

var player: Node3D
var prompt_label: Label3D
var dialogue_label: Label3D
var gravity: float = 9.8

func _ready() -> void:
    add_to_group("npcs")
    player = get_tree().current_scene.get_node_or_null("Player") as Node3D

    prompt_label = Label3D.new()
    prompt_label.text = "Press E to talk"
    prompt_label.font_size = 48
    prompt_label.position = Vector3(0, 2.25, 0)
    prompt_label.pixel_size = 0.005
    prompt_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(prompt_label)

    dialogue_label = Label3D.new()
    dialogue_label.text = ""
    dialogue_label.font_size = 36
    dialogue_label.position = Vector3(0, 3.0, 0)
    dialogue_label.pixel_size = 0.005
    dialogue_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(dialogue_label)
    _refresh_prompt()

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
    if not _player_is_near():
        dialogue_label.visible = false

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
    dialogue_label.text = npc_name + ": " + message
    dialogue_label.visible = true
    prompt_label.text = "Press E to talk again"

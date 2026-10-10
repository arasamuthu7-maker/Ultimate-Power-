extends CharacterBody3D

@export var move_speed: float = 3.0
@export var max_health: float = 100.0
@export var contact_damage: float = 10.0
@export var attack_range: float = 1.8
@export var attack_cooldown: float = 1.0

var health: float
var attack_timer: float = 0.0
var target: Node3D
var gravity: float = 9.8

signal health_changed(current_health: float, maximum_health: float)
signal defeated

func _ready() -> void:
    health = max_health
    var player := get_tree().current_scene.get_node_or_null("Player")
    if player is Node3D:
        target = player

func _physics_process(delta: float) -> void:
    if attack_timer > 0.0:
        attack_timer -= delta

    if not is_on_floor():
        velocity.y -= gravity * delta

    if is_instance_valid(target):
        var offset: Vector3 = target.global_position - global_position
        offset.y = 0.0
        var distance := offset.length()

        if distance > attack_range and distance > 0.01:
            var direction := offset.normalized()
            velocity.x = direction.x * move_speed
            velocity.z = direction.z * move_speed
            look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
        else:
            velocity.x = 0.0
            velocity.z = 0.0
            if attack_timer <= 0.0:
                _attack_target()
                attack_timer = attack_cooldown
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed)
        velocity.z = move_toward(velocity.z, 0.0, move_speed)

    move_and_slide()

func take_damage(amount: float) -> void:
    if amount <= 0.0 or health <= 0.0:
        return

    health = maxf(health - amount, 0.0)
    health_changed.emit(health, max_health)

    if health <= 0.0:
        defeated.emit()
        queue_free()

func _attack_target() -> void:
    if not is_instance_valid(target):
        return

    if target.has_method("take_damage"):
        target.take_damage(contact_damage)

extends Node

signal health_changed(current_health: float, maximum_health: float)
signal defeated

@export var max_health: float = 100.0
var current_health: float = 100.0

func _ready() -> void:
    current_health = max_health

func take_damage(amount: float) -> void:
    if amount <= 0.0 or current_health <= 0.0:
        return
    current_health = maxf(0.0, current_health - amount)
    health_changed.emit(current_health, max_health)
    if current_health <= 0.0:
        defeated.emit()

func heal(amount: float) -> void:
    if amount <= 0.0 or current_health <= 0.0:
        return
    current_health = minf(max_health, current_health + amount)
    health_changed.emit(current_health, max_health)

func get_health_ratio() -> float:
    if max_health <= 0.0:
        return 0.0
    return current_health / max_health

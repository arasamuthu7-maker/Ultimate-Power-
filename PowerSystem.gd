extends Node

signal power_used(power_name: String, cooldown_seconds: float)

# Starter ability data for Ultimate Power Simulator.
# This is a foundation only; enemy damage and visual effects will be connected later.
var powers := {
    "Energy Blast": {
        "cooldown": 2.0,
        "damage": 20.0,
        "range": 12.0
    },
    "Ground Smash": {
        "cooldown": 5.0,
        "damage": 35.0,
        "range": 5.0
    },
    "Power Dash": {
        "cooldown": 3.0,
        "damage": 0.0,
        "range": 8.0
    }
}

var cooldown_left: Dictionary = {}

func _process(delta: float) -> void:
    for power_name in cooldown_left.keys():
        cooldown_left[power_name] = maxf(0.0, float(cooldown_left[power_name]) - delta)

func can_use_power(power_name: String) -> bool:
    return powers.has(power_name) and float(cooldown_left.get(power_name, 0.0)) <= 0.0

func use_power(power_name: String) -> bool:
    if not can_use_power(power_name):
        return false

    var power: Dictionary = powers[power_name]
    var cooldown := float(power["cooldown"])
    cooldown_left[power_name] = cooldown
    power_used.emit(power_name, cooldown)
    return true

func get_power_info(power_name: String) -> Dictionary:
    if not powers.has(power_name):
        return {}
    return powers[power_name].duplicate(true)

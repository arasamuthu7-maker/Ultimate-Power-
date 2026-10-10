extends Node
## Session progression for Ultimate Power Simulator.
signal progress_changed(level: int, xp: int, coins: int)
signal quest_changed(quest_name: String, completed: bool)

var level: int = 1
var xp: int = 0
var coins: int = 0
var attack_bonus: float = 0.0
var quests: Dictionary = {
    "Defeat 3 Void Fighters": {"target": 3, "progress": 0, "reward_xp": 60, "reward_coins": 40, "done": false},
    "Reach Level 2": {"target": 2, "progress": 1, "reward_xp": 30, "reward_coins": 20, "done": false}
}

func add_xp(amount: int) -> void:
    if amount <= 0: return
    xp += amount
    while xp >= level * 100:
        xp -= level * 100
        level += 1
        coins += 25
    _check_level_quest()
    progress_changed.emit(level, xp, coins)

func add_coins(amount: int) -> void:
    coins += maxi(0, amount)
    progress_changed.emit(level, xp, coins)

func enemy_defeated(is_boss: bool = false) -> void:
    add_xp(100 if is_boss else 25)
    add_coins(100 if is_boss else 10)
    if not is_boss and quests.has("Defeat 3 Void Fighters"):
        var q: Dictionary = quests["Defeat 3 Void Fighters"]
        if not q["done"]:
            q["progress"] += 1
            if q["progress"] >= q["target"]:
                q["done"] = true
                xp += int(q["reward_xp"])
                coins += int(q["reward_coins"])
                _level_up_if_needed()
                quest_changed.emit("Defeat 3 Void Fighters", true)
    progress_changed.emit(level, xp, coins)

func _check_level_quest() -> void:
    if level >= 2 and quests.has("Reach Level 2"):
        var q: Dictionary = quests["Reach Level 2"]
        if not q["done"]:
            q["done"] = true
            xp += int(q["reward_xp"])
            coins += int(q["reward_coins"])
            quest_changed.emit("Reach Level 2", true)
            _level_up_if_needed()

func _level_up_if_needed() -> void:
    while xp >= level * 100:
        xp -= level * 100
        level += 1
        coins += 25

func buy_attack_upgrade() -> bool:
    if coins < 50: return false
    coins -= 50
    attack_bonus += 5.0
    progress_changed.emit(level, xp, coins)
    return true

func quest_status() -> String:
    var q: Dictionary = quests["Defeat 3 Void Fighters"]
    return "Void Fighters: %d/%d" % [int(q["progress"]), int(q["target"])]

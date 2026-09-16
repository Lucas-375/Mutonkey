## Component to manage health with an entity.
## Handles damage intake and heal logic, and emits signals.
class_name HealthComponent
extends Node

@export var max_health: int = 100
var current_health: int = max_health

signal died
signal health_changed(new_health)

func set_health(value: int) -> void:
    # Clamp the value to be in between the wanted range
    current_health = clampi(value, 0, max_health)

    health_changed.emit(current_health)
    
    if current_health == 0:
        died.emit()

func apply_damage(amount_to_damage: int) -> void:
    if amount_to_damage <= 0:
        return
    
    var new_health = current_health - amount_to_damage
    set_health(new_health)

func apply_heal(amount_to_heal: int) -> void:
    if amount_to_heal <= 0:
        return
    
    var new_health = current_health + amount_to_heal
    set_health(new_health)
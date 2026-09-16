## Component to manage health with an entity.
## Handles damage intake and heal logic, and emits signals.
class_name HealthComponent
extends Node

@export var max_health: int = 100
var current_health: int = max_health

signal died
signal health_changed(new_health)

func get_health() -> int:
    return current_health

func set_health(value: int) -> void:
    # Clamp the value to be in between the wanted range
    current_health = clampi(value, 0, max_health)

    health_changed.emit(current_health)
    
    if current_health == 0:
        died.emit()

## Applies damage to the entity.
## Returns the actual amount of health removed (positive integer).
func apply_damage(amount_to_damage: int) -> int:
    if amount_to_damage <= 0:
        return 0 # Returns if the argument passed is negative

    var old_health = current_health    
    set_health(current_health - amount_to_damage)

    return old_health - current_health # Returns how much health was actually removed

## Applies heal to the entity.
## Returns the actual amount of health added (positive integer).
func apply_heal(amount_to_heal: int) -> int:
    if amount_to_heal <= 0:
        return 0 # Returns if the argument passed is negative
    
    var old_health = current_health
    set_health(current_health + amount_to_heal)

    return current_health - old_health # Returns how much health was actually added

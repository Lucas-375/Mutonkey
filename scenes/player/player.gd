## Player entity root.
## Acts as a container and orchestrator for gameplay systems.
## Holds references to components and inventory.
## Delegates all gameplay behaviour to its systems,
## does not implement logic directly (not like a god-class).
extends CharacterBody2D
class_name Player

## Player's inventory resource.
@export var inventory: Inventory

var movement_component: MovementComponent
var health_component: HealthComponent

func _ready() -> void:
    movement_component = $MovementComponent
    health_component = $HealthComponent

extends Node2D

@onready var player: Player = $Player

func _ready() -> void:
    print("HP: ", player.health_component.get_health())

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        # Damage
        if event.keycode == KEY_O:
            ## The amount actually removed from the player's health. 
            var health_removed: int = player.health_component.apply_damage(10)
            print("HP: %d (-%d)" % [player.health_component.get_health(), health_removed])
        # Heal
        if event.keycode == KEY_P:
            ## The amount actually added to the player's health.
            var health_added: int = player.health_component.apply_heal(10)
            print("HP: %d (+%d)" % [player.health_component.get_health(), health_added])

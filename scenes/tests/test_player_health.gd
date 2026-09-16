extends Node2D

@onready var player: Player = $Player

func _ready() -> void:
    print(
        "HP: ", 
        player.health_component.get_health()
    )

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
            # Damage
            if event.keycode == KEY_O:
                var damage: int = 10
                player.health_component.apply_damage(damage)
                print("HP: %d (-%d)" % [player.health_component.get_health(), damage])
            # Heal
            if event.keycode == KEY_P:
                var heal: int = 10
                player.health_component.apply_heal(heal)
                print("HP: %d (+%d)" % [player.health_component.get_health(), heal])

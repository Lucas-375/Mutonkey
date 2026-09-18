## Hurtbox detects collisions with Hitbox.
## Emit signals for other components to respond to the hit.
class_name HurtboxComponent
extends Area2D

## Signal emitted when Hitbox enters the Hurtbox
signal hit(attack_data: AttackData)

func _ready() -> void:
    connect('area_entered', _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if area is HitboxComponent:
        hit.emit(area.attack_data)

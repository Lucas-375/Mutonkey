## Defines the parameters for a combat attack.
class_name AttackData
extends Resource

@export var attack_id: String
@export var display_name: String
@export var damage: int = 10
## Time before the attack becomes active (hitbox). 
@export var wind_up: float = 0.1
## Active time when the hitbox can deal damage.
@export var duration: float = 0.1
## Delay before the attack can be used again.
@export var cooldown: float = 0.3

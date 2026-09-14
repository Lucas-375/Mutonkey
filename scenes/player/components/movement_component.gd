## Handles player movement math, velocity calculation, and application.
## This component is used by the MovementStateMachine to control the player's movement.
class_name MovementComponent
extends Node

@export var character: CharacterBody2D
# ## The player's max speed
# @export var speed: float = 100.0

## The player's current velocity
var velocity: Vector2 = Vector2.ZERO
## The player's current movement direction, from (-1, -1) to (1, 1)
var direction: Vector2 = Vector2.ZERO
## The player's last movement direction, used for dash and other movement logic
var last_movement_direction: Vector2 = Vector2.ZERO

## The player can dash if this is true. This is set to false when the player dashes, and reset to true after the dash cooldown.
var can_dash: bool = true

## The player's standard/base run speed. Set by RunState on registration.
var run_speed: float = 0

func set_direction(new_direction: Vector2) -> void:
    if new_direction != Vector2.ZERO:
        last_movement_direction = direction
    direction = new_direction.normalized()

func get_movement_direction() -> Vector2:
    return direction

func get_last_movement_direction() -> Vector2:
    return last_movement_direction

func set_velocity(new_velocity: Vector2) -> void:
    velocity = new_velocity
    set_direction(new_velocity.normalized())

    if character:
        character.velocity = new_velocity

func _physics_process(_delta: float) -> void:
    if character:
        # calculate_velocity()
        character.velocity = velocity
        character.move_and_slide()

func zero_velocity() -> void:
    set_velocity(Vector2.ZERO)
    if character:
        character.velocity = Vector2.ZERO

func is_moving() -> bool:
    return direction != Vector2.ZERO

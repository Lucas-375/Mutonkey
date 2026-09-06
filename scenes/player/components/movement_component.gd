## Handles player movement input and velocity calculation logic. 
## This component is used by the MovementStateMachine to control the player's movement.
class_name MovementComponent
extends Node

## The player's max speed
@export var speed: float = 100.0
## The player's current movement direction, from (-1, -1) to (1, 1)
@export var direction: Vector2 = Vector2.ZERO
## The player's current velocity
@export var velocity: Vector2 = Vector2.ZERO

## Returns the direction of movement based on input actions
func get_movement_input():
    direction = Vector2.ZERO
    if Input.is_action_pressed("move_up"):
        direction.y -= 1
    if Input.is_action_pressed("move_down"):
        direction.y += 1
    if Input.is_action_pressed("move_left"):
        direction.x += 1
    if Input.is_action_pressed("move_right"):
        direction.x -= 1
    
    return direction

### Returns true if the player is currently moving, false otherwise
func is_moving() -> bool:
    return get_movement_input() != Vector2.ZERO
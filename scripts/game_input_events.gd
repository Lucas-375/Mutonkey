## Autoload responsible for all game input events.
## Contains functions to return what the input means, such as a Vector or bool.

# --- Movement Input Constants ---
const MOVE_LEFT = "move_left"
const MOVE_RIGHT = "move_right"
const MOVE_UP = "move_up"
const MOVE_DOWN = "move_down"

const DASH = "dash"

## Returns the Vector for basic movement input (left, right, up, down)
func movement_input() -> Vector2:
    var direction = Input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN)
    return direction

## Returns true if the player is performing the input to move.
func is_movement_input() -> bool:
    return movement_input() != Vector2.ZERO

## Returns the Vector2 for dash input if player 
## is performing the dash input and is also moving. 
## Returns Vector2.ZERO if not.
func dash_input() -> Vector2:
    if Input.is_action_just_pressed(DASH) and is_movement_input():
        var dir := movement_input()
        if dir != Vector2.ZERO:
            return dir
    return Vector2.ZERO

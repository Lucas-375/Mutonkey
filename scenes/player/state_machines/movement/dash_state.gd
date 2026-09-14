class_name DashState
extends NodeState

@onready var color_rect: ColorRect = $'../../ColorRect'

@export var dash_speed: float = 400
## How far the character will dash for.
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.0

var dash_cooldown_timer: Timer
var can_dash: bool = true
var dash_in_progress: bool = false
var dash_finished: bool = false

func _ready() -> void:
    # Initialize the dash cooldown timer
    dash_cooldown_timer = Timer.new()
    dash_cooldown_timer.wait_time = dash_cooldown
    dash_cooldown_timer.one_shot = true
    dash_cooldown_timer.connect("timeout", Callable(self, "_on_dash_cooldown_timeout"))
    add_child(dash_cooldown_timer)

func _on_enter() -> void:    
    color_rect.color = Color.AQUA

    dash_in_progress = true
    dash_finished = false
    movement_component.can_dash = false

    # Set movement velocity and direction for the dash
    var direction = movement_component.get_movement_direction()
    movement_component.set_velocity(direction * dash_speed)

    var tween = create_tween()
    tween.tween_property(
        movement_component,
        "velocity",
        direction * movement_component.run_speed, # The player's base speed
        dash_duration
    ).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    
    tween.finished.connect(_on_dash_finished)

func _on_next_transitions() -> void:
    # Transition back to IdleState when the dash is finished or if the player cannot dash
    if not dash_in_progress and GameInputEvents.dash_input() != Vector2.ZERO:
        transition.emit('RunState')
    elif not dash_in_progress and dash_finished:
        transition.emit("IdleState")
    

func _on_exit() -> void:
    color_rect.color = Color.GREEN

func _on_dash_finished() -> void:
    dash_in_progress = false
    dash_finished = true
    movement_component.can_dash = false
    dash_cooldown_timer.start() # Start the dash cooldown timer when the dash is finished
    
func _on_dash_cooldown_timeout() -> void:
    movement_component.can_dash = true

class_name RunState
extends NodeState

@onready var color_rect: ColorRect = $'../../ColorRect'

@export var speed: float = 200.0

var direction_to_move: Vector2

func _physics_update(_delta: float) -> void:
    direction_to_move = GameInputEvents.movement_input()
    movement_component.set_velocity(direction_to_move * speed)

func _on_enter() -> void:
    movement_component.run_speed = speed
    color_rect.color = Color.RED

func _on_next_transitions() -> void:
    if direction_to_move == Vector2.ZERO:
        transition.emit("IdleState")
    
    if GameInputEvents.dash_input() != Vector2.ZERO and movement_component.can_dash:
        transition.emit("DashState")

func _on_exit() -> void: 
    color_rect.color = Color.GREEN

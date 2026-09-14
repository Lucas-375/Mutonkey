class_name IdleState
extends NodeState

@onready var color_rect: ColorRect = $'../../ColorRect'

func _on_enter() -> void:
	movement_component.zero_velocity()
	color_rect.color = Color.BLUE

func _on_next_transitions() -> void:
	var dir := GameInputEvents.movement_input()
	if dir != Vector2.ZERO:
		transition.emit('RunState')

func _on_exit() -> void:
	color_rect.color = Color.GREEN

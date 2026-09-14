## Base class for all states used by NodeStateMachine.
## Defines lifecycle callbacks for entering, exiting, and processing states,
## which are called automatically by the state machine.
## Subclasses should override these methods to implement custom behavior.
class_name NodeState
extends Node

var movement_component: MovementComponent

@warning_ignore('unused_signal')
signal transition

func _ready() -> void:
	pass

func _update(_delta: float) -> void:
	pass

func _physics_update(_delta: float) -> void:
	pass

## Called when the state is entered
func _on_enter() -> void:
	pass

## Called to check for possible transitions, if any, emit the transition signal
func _on_next_transitions() -> void:
	pass

## Called when the state is exited
func _on_exit() -> void:
	pass

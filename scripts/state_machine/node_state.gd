class_name NodeState
extends Node

@warning_ignore('unused_signal')
signal transition

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
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

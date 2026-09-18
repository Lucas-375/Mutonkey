## Manages all player movement states and transitions.
## Delegates movement logic to movement component and coordinates state behoavior
## such as idle, running, dash, etc.
class_name MovementStateMachine
extends NodeStateMachine

@export var movement_component: MovementComponent

func _on_state_registration(_node_state_name: String) -> void:
    var node_state = states.get(_node_state_name) as NodeState

    if node_state:
        node_state.movement_component = movement_component

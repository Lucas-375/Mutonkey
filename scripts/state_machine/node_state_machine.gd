## Base class for all state machines.
## Registers state machine children, manages active state, and handles transitions 
## triggered by signals. Provides lifecycle hooks (_on_enter_state and _on_exit_state)
## for subclasses to implement custom logic when a state changes.
class_name NodeStateMachine
extends Node

@export var initial_node_state: NodeState

var node_states: Dictionary[String, NodeState] = {}
var current_node_state: NodeState
var current_node_state_name: String
var parent_name: String

func _ready() -> void:
    parent_name = get_parent().name

    for child in get_children():
        if child is NodeState:
            node_states[child.name.to_lower()] = child # Add child to dict
            child.transition.connect(transition_to) # Set up transition signal connection
    
    # Set the initial state
    if initial_node_state:
        initial_node_state._on_enter()
        current_node_state = initial_node_state
        current_node_state_name = initial_node_state.name.to_lower()

func _process(_delta: float) -> void:
    if current_node_state:
        current_node_state._process(_delta)

func _physics_process(_delta: float) -> void:
    if current_node_state:
        current_node_state._physics_process(_delta)
        # Check for possible transitions
        current_node_state._on_next_transitions()

## Called when a state is entered, to be overridden by subclasses if needed
func _on_enter_state(_node_state_name: String) -> void:
    pass

## Called when a state is exited, to be overridden by subclasses if needed
func _on_exit_state(_node_state_name: String) -> void:
    pass

func transition_to(node_state_name: String) -> void:
    if node_state_name.to_lower() == current_node_state_name:
        return
    
    var new_node_state: NodeState = node_states.get(node_state_name.to_lower())

    if not new_node_state:
        return 

    if current_node_state:
        _on_exit_state(current_node_state_name) # Call the instantiated state machine's exit logic
        current_node_state._on_exit()
    
    _on_enter_state(new_node_state.name.to_lower()) # Call the instantiated state machine's enter logic
    new_node_state._on_enter()

    # Update the current state and its name
    current_node_state = new_node_state
    current_node_state_name = current_node_state.name.to_lower()
    
    # print(parent_name, " -> Current State: ", current_node_state_name)

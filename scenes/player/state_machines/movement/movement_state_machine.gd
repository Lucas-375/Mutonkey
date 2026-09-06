## Manages all player movement states and transitions.
## Delegates movement logic to movement component and coordinates state behoavior
## such as idle, running, dash, etc.
class_name MovementStateMachine
extends NodeStateMachine

@export var movement_component: Variant
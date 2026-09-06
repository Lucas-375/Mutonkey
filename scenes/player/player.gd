extends CharacterBody2D
class_name Player

@export var inventory: Inventory
@export var move_speed: float = 100

var movement := PlayerMovement.new()

func _ready() -> void:
	self.add_to_group('player')
	movement.init(self)

func _physics_process(delta: float) -> void:
	movement.move(delta)

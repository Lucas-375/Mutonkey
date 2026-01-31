extends Node
class_name CollectableComponent

@export var root_to_delete: Node = null
@export var item: Item
@export var amount := 1 

func _ready() -> void:
	var area := get_parent()
	area.body_entered.connect(on_body_entered)

func on_body_entered(body):
	if body is Player:
		if root_to_delete:
			root_to_delete.queue_free()
		else:
			queue_free()

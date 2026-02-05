extends Control
class_name InventorySlot

@export var index: int
@export var inventory: Inventory


func update_slot():
	var stack = inventory.slots[index]
	
	if stack == null:
		$Icon.hide()
		$CountLabel.hide()
		return
	
	if stack.item.display_texture:
		$Icon.show()
		$Icon.texture = stack.item.display_texture
	
	if stack.quantity == 1:
		$CountLabel.hide()
	else:
		$CountLabel.show()
		$CountLabel.text = str(stack.quantity)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			InventoryActions.primary_interaction(inventory, index)

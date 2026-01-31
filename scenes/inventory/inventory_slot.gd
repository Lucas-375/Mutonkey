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
	
	$CountLabel.show()
	$CountLabel.text = str(stack.quantity)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			CursorManager.handle_left_click(inventory, index)
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			CursorManager.handle_right_click(inventory, index)

extends Control
class_name InventorySlot

@export var index: int
@export var inventory: Inventory
@export var stack: ItemStack


func update_slot():
	if inventory and index:
		stack = inventory.slots[index]
	
	if stack == null:
		$Icon.hide()
		$CountLabel.hide()
		return
	
	if stack.item.display_texture:
		print(stack.item.display_name)
		print($Icon)
		$Icon.show()
		$Icon.texture = stack.item.display_texture
	
	if stack.quantity == 1:
		$CountLabel.hide()
	else:
		$CountLabel.show()
		$CountLabel.text = str(stack.quantity)

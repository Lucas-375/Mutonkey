extends Control
class_name InventorySlot

@onready var item_ui_display: ItemUIDisplay = $ItemUIDisplay

@export var index: int
@export var inventory: Inventory
@export var stack: ItemStack


func update_slot():
	if inventory and inventory.is_valid_index(index):
		stack = inventory.get_slot(index)
		if stack == null:
			item_ui_display.update_display(null, 0)
		else:
			item_ui_display.update_display(stack.item, stack.quantity)

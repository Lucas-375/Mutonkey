extends Control
class_name InventorySlot

@onready var item_ui: Control = $ItemUI
@onready var icon: TextureRect = $ItemUI/Icon
@onready var count_label: Label = $ItemUI/CountLabel

@export var index: int
@export var inventory: Inventory
@export var stack: ItemStack

func _ready() -> void:
	# Ignore mouse on child nodes so clicks pass through to the main slot
	item_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_slot():
	if inventory and inventory.is_valid_index(index):
		stack = inventory.get_slot(index)
	
	# If slot is empty, hide the entire UI layer and clear the image
	if stack == null or stack.item == null:
		item_ui.hide()
		icon.texture = null
		return
	
	# Item exists, so show the UI container
	item_ui.show()
	
	if stack.item.display_texture:
		icon.show()
		icon.texture = stack.item.display_texture
	else:
		icon.hide()
	
	# Toggle count label based on quantity
	if stack.quantity == 1:
		count_label.hide()
	else:
		count_label.show()
		count_label.text = str(stack.quantity)

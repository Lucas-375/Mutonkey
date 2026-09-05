extends Control

@onready var grid_container: GridContainer = $GridContainer
@onready var cursor_item_ui: ItemUIDisplay = $CursorItemUI

@export var inventory: Inventory
@export var columns: int = 8
@export var slot_scene: PackedScene

var _left_click_held := false
var _right_click_held := false

## Index hovered by mouse, -1 represents that no slot is hovered.
var _hovered_index := -1

func _ready() -> void:
	# Set up UI
	grid_container.columns = columns

	# Set up inventory
	inventory.inventory_changed.connect(on_inventory_changed)
	inventory.slot_changed.connect(on_slot_changed)
	create_slots()
	refresh_all()

	# Set up cursor item display
	InventoryCursor.content_changed.connect(on_cursor_content_changed)

func _process(_delta: float) -> void:
	# Update the floating item position to follow the cursor smoothly
	if cursor_item_ui.visible:
		cursor_item_ui.global_position = get_global_mouse_position()

	if _hovered_index == -1:
		return # Returns if no index is being hovered

	# Calls Primary and Secondary interactions
	# Both block collisions of clicking the opposite button during the drag
	if _right_click_held and not _left_click_held: # Blocks left-click
		InventoryActions.secondary_interaction(inventory, _hovered_index)
	
	if _left_click_held and not _right_click_held: # Blocks right-click
		InventoryActions._update_primary_drag(inventory, _hovered_index)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _right_click_held:
					return # Blocks left-click during right-click drag
				_left_click_held = true
				if _hovered_index != -1:
					InventoryActions.primary_interaction(inventory, _hovered_index)
			else:
				_left_click_held = false
				InventoryActions._end_primary_drag()
				
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if _left_click_held:
					return # Blocks right-click during left-click drag
				_right_click_held = true
				if _hovered_index != -1:
					InventoryActions.secondary_interaction(inventory, _hovered_index)
			else:
				_right_click_held = false 
				InventoryActions.end_interaction_session()
		

func create_slots():
	for i in range(inventory.slots.size()):
		var slot_instance := slot_scene.instantiate() as InventorySlot
		# Set slot's variables
		slot_instance.index = i
		slot_instance.inventory = inventory
		
		# Connect the slot's signals to slot hovered / unhovered functions
		slot_instance.mouse_entered.connect(func(): _on_slot_hovered(i))
		slot_instance.mouse_exited.connect(func(): _on_slot_unhovered(i))
		
		grid_container.add_child(slot_instance) # Add instance to inventory

## Updates the cursor item display to match the item stack in the InventoryCursor singleton. If there is no item stack, it hides the display.
func on_cursor_content_changed(cursor_stack: ItemStack):
	if cursor_stack == null:
		cursor_item_ui.update_display(null, 0)
	else:
		cursor_item_ui.update_display(cursor_stack.item, cursor_stack.quantity)

## Refreshes all slots in the inventory UI to match the current state of the inventory. This is useful when the inventory has changed significantly, such as after adding or removing items.
func refresh_all():
	for slot: InventorySlot in grid_container.get_children():
		slot.update_slot()

## Refreshes a specific slot in the inventory UI to match the current state of the inventory at the given index.
func refresh_index(index: int):
	if not inventory.is_valid_index(index):
		return
	var slot := grid_container.get_child(index) as InventorySlot
	slot.update_slot()

func _on_slot_hovered(index: int):
	_hovered_index = index

func _on_slot_unhovered(index: int):
	if _hovered_index == index:
		_hovered_index = -1

func on_inventory_changed():
	refresh_all()

func on_slot_changed(index: int):
	refresh_index(index)

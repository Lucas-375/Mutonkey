extends Node

signal cursor_stack_changed(new_stack: ItemStack)

@export var cursor_stack: ItemStack = null

var right_click_pressed: bool = false:
	set(value):
		right_click_pressed = value
		if right_click_pressed == false:
			last_added_inventory = null
			last_added_index = -1

## Last inventory modified through adding one to stack on right click.
var last_added_inventory: Inventory = null
## Last slot's index modified through adding one to stack on right click.
var last_added_index: int = -1

## Sets the cursor stack to `value`.
func set_cursor_stack(value: ItemStack):
	cursor_stack = value
	cursor_stack_changed.emit(cursor_stack)

## Clears cursor stack to null.
func clear_cursor_stack():
	set_cursor_stack(null)

## Swaps the cursor stack with the stack in the given slot.
func _swap_with_cursor(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	inventory.set_slot(index, cursor_stack)
	set_cursor_stack(slot_stack)

## Adds up to `amount` to the cursor stack.
## Returns the leftover that could not fit.
func add_to_cursor(amount: int) -> int:
	if not cursor_stack:
		return amount
	 
	var max_stack := cursor_stack.item.max_stack
	var space := max_stack - cursor_stack.quantity
	
	if space <= 0:
		return amount
	
	var to_add = min(space, amount)
	cursor_stack.quantity += to_add
	set_cursor_stack(cursor_stack)
	
	# Leftover that did not fit
	return amount - to_add

## Removes up to `amount` from the cursor stack.
## Returns the leftover that could not be removed.
func remove_from_cursor(amount: int) -> int:
	if not cursor_stack:
		return amount
	
	# Subtract the `amount` and keep remaining stack
	if amount < cursor_stack.quantity:
		cursor_stack.quantity -= amount
		set_cursor_stack(cursor_stack)
		return 0
	
	# amount >= quantity -> remove everything
	var leftover := amount - cursor_stack.quantity
	clear_cursor_stack()
	
	return leftover

#region Left Click Helpers
## Returns true if the cursor is empty and the slot contains a stack.
func _can_pick_up(slot_stack: ItemStack) -> bool:
	return cursor_stack == null and slot_stack != null

## Moves the stack from the slot into the cursor and clears the slot.
func _pick_up(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	set_cursor_stack(slot_stack)
	inventory.clear_slot(index)

## Returns true if the cursor contains a stack and the slot is empty.
func _can_place_stack(slot_stack: ItemStack) -> bool:
	return cursor_stack != null and slot_stack == null

## Moves the stack from the cursor into the slot and clears the cursor.
func _place_stack(inventory: Inventory, index: int):
	inventory.set_slot(index, cursor_stack)
	clear_cursor_stack()

## Returns true if both stacks exist and contain the same item.
func _can_merge(slot_stack: ItemStack) -> bool:
	return (
		cursor_stack != null 
		and slot_stack != null 
		and cursor_stack.item == slot_stack.item
	)

## Merges the cursor stack with the slot stack, moving their items.
func _merge(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	var max_stack := slot_stack.item.max_stack
	var space := max_stack - slot_stack.quantity
	
	# With space, remove from cursor and add to inventory slot
	if space > 0:
		var amount_to_move = min(space, cursor_stack.quantity)
		inventory.add_to_stack(index, amount_to_move)
		remove_from_cursor(amount_to_move)
	
	elif cursor_stack.quantity < slot_stack.quantity:
		_swap_with_cursor(inventory, index)

## Returns true if both stacks exists and contain the different items.
func _can_swap(slot_stack: ItemStack) -> bool:
	return (
		cursor_stack != null
		and slot_stack != null
		and cursor_stack.item != slot_stack.item
	)
#endregion

## Handles all left-click interactions in the Invetory UI.
## Performs picking up, placing, merging, and swapping item stacks.
func handle_left_click(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	
	if _can_pick_up(slot_stack):
		_pick_up(inventory, index)
		return
	
	elif _can_place_stack(slot_stack):
		_place_stack(inventory, index)
		return
	
	elif _can_merge(slot_stack):
		_merge(inventory, index)
		return
	
	elif _can_swap(slot_stack):
		_swap_with_cursor(inventory, index)
		return

#region Right Click Helpers
## Returns true if the cursor is empty and the slot contains a stack.
func _can_pick_up_half(slot_stack: ItemStack) -> bool:
	return cursor_stack == null and slot_stack != null

## Moves half of the slot into the cursor.
func _pick_up_half(inventory: Inventory, index: int):
	var slot_stack = inventory.get_slot(index)
	if slot_stack == null:
		return
	
	var half = ceil(float(slot_stack.quantity) / 2)
	if half <= 0:
		return
	
	inventory.remove_from_stack(index, half)
	
	if cursor_stack == null:
		set_cursor_stack(ItemStack.new(slot_stack.item, half))
	else:
		add_to_cursor(half)

## Returns true if the cursor contains an item and the slot is empty.
func _can_place_one_into_empty(inventory: Inventory, index: int) -> bool:
	var slot_stack := inventory.get_slot(index)
	
	return (
		cursor_stack != null
		and slot_stack == null
		and not (
			inventory == last_added_inventory 
			and index == last_added_index
		)
	)

## Removes one from cursor and places one into the empty slot.
func _place_one_into_empty(inventory: Inventory, index: int):
	if cursor_stack == null:
		return
	
	var slot_stack := inventory.get_slot(index)
	if slot_stack != null:
		return
	
	last_added_inventory = inventory
	last_added_index = index
	print(str(last_added_index))
	
	var new_stack := ItemStack.new(cursor_stack.item, 1)
	remove_from_cursor(1)
	inventory.set_slot(index, new_stack)

## Returns true if both stacks exist, both stacks have the same item,
## and the slot stack is not full.
func _can_place_one_into_same(inventory: Inventory, index: int) -> bool:
	var slot_stack := inventory.get_slot(index)
	
	return (
		cursor_stack != null
		and slot_stack != null
		and cursor_stack.item == slot_stack.item
		and slot_stack.quantity < slot_stack.item.max_stack
		and not (
			inventory == last_added_inventory 
			and index == last_added_index
		)
	)

## Removes one from the cursor and adds it to the slot stack.
func _place_one_into_same(inventory: Inventory, index: int):
	if cursor_stack == null:
		return
	
	var slot_stack := inventory.get_slot(index)
	if slot_stack == null:
		return
	
	last_added_inventory = inventory
	last_added_index = index
	
	remove_from_cursor(1)
	inventory.add_to_stack(index, 1)

#endregion

## Handles all right-click interactions in the Invetory UI.
## Performs picking up half and placing one item.
func handle_right_click(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	
	if _can_pick_up_half(slot_stack):
		_pick_up_half(inventory, index)
		return
	
	elif _can_place_one_into_empty(inventory, index):
		_place_one_into_empty(inventory, index)
		return
	
	elif _can_place_one_into_same(inventory, index):
		_place_one_into_same(inventory, index)
		return

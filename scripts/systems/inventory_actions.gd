extends Node
class_name InventoryActions

static var _last_interacted_slot: int = -1
static var _last_interacted_inv: Inventory = null

static var _drag_inventory: Inventory = null
static var _drag_starting_stack: ItemStack = null
static var _drag_indices: Array[int] = []


static func primary_interaction(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	var held := InventoryCursor.get_item_stack()
	
	if not held:
		if slot_stack:
			_take_all(inventory, index)
		return
	
	_drag_indices = [index]
	_drag_inventory = inventory
	_drag_starting_stack = held	

## The alternate interaction (Splif half, Drop single)
static func secondary_interaction(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	var held := InventoryCursor.get_item_stack()
	
	# Prevent repeated logic on the same slot while dragging
	if (_last_interacted_inv == inventory 
	and _last_interacted_slot == index):
		return
	
	if not held and slot_stack:
		_split_to_cursor(inventory, index)
	elif held:
		_drop_single_to_slot(inventory, index)
	
	print(str(_last_interacted_slot))


static func end_interaction_session():
	_last_interacted_inv = null
	_last_interacted_slot = -1

static func clean_up_drag():
	_drag_indices = []
	_drag_inventory = null
	_drag_starting_stack = null

# --- Helpers ---

static func _end_primary_drag():
	if _drag_indices.is_empty():
		clean_up_drag()
	
	elif _drag_indices.size() == 1:
		_handle_single_place_or_swap(_drag_inventory, _drag_indices[0])
	
	else:
		_distribute_held_stack()
	
	clean_up_drag()

static func _handle_single_place_or_swap(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	var held := InventoryCursor.get_item_stack()
	if not held:
		return
	
	if not slot_stack:
		_place_all(inventory, index)
	elif slot_stack.item == held.item:
		_merge_stacks(inventory, index)
	else:
		_swap_with_cursor(inventory, index)

static func _update_primary_drag(inventory: Inventory, index: int):
	if inventory != _drag_inventory or index in _drag_indices:
		return
	
	var slot_stack := _drag_inventory.get_slot(index)
	
	if slot_stack == null or _drag_starting_stack.item == slot_stack.item:
		_drag_indices.append(index)

static func _distribute_held_stack():
	var held := InventoryCursor.get_item_stack()
	if not held:
		return
	
	var count := _drag_indices.size()
	var amount_per_slot := int(float(held.quantity) / count)
	
	if amount_per_slot == 0:
		return
	
	for idx in _drag_indices:
		var slot_stack := _drag_inventory.get_slot(idx)
		
		if slot_stack == null or slot_stack.item == held.item:
			var current_quantity := 0 if not slot_stack else slot_stack.quantity
			var space := held.item.max_stack - current_quantity
			
			var to_add = min(space, amount_per_slot)
			
			if not slot_stack:
				_drag_inventory.set_slot(idx, ItemStack.new(held.item, to_add))
			else:
				_drag_inventory.add_to_stack(idx, to_add)
			
			InventoryCursor.subtract(to_add)

static func _take_all(inventory: Inventory, index: int):
	InventoryCursor.set_item_stack(inventory.get_slot(index))
	inventory.clear_slot(index)

static func _place_all(inventory: Inventory, index: int):
	inventory.set_slot(index, InventoryCursor.get_item_stack())
	InventoryCursor.clear()

static func _swap_with_cursor(inventory: Inventory, index: int):
	var temp := inventory.get_slot(index)
	inventory.set_slot(index, InventoryCursor.get_item_stack())
	InventoryCursor.set_item_stack(temp)

static func _merge_stacks(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	var space = max(slot_stack.item.max_stack - slot_stack.quantity, 0)
	
	if space == 0:
		return
	
	var held := InventoryCursor.get_item_stack()
	var amount_to_move = min(space, held.quantity)
	
	inventory.add_to_stack(index, amount_to_move)
	InventoryCursor.subtract(amount_to_move)

static func _split_to_cursor(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	var half = ceil(float(slot_stack.quantity) / 2)
	var new_stack := ItemStack.new(slot_stack.item, half)
	InventoryCursor.set_item_stack(new_stack)
	inventory.remove_from_stack(index, half)

static func _drop_single_to_slot(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	var held := InventoryCursor.get_item_stack()
	
	if not slot_stack:
		_last_interacted_inv = inventory
		_last_interacted_slot = index
		
		var new_stack := ItemStack.new(held.item, 1)
		
		inventory.set_slot(index, new_stack)
		InventoryCursor.subtract(1)
	
	elif (slot_stack.item == held.item 
	and slot_stack.quantity < slot_stack.item.max_stack):
		_last_interacted_inv = inventory
		_last_interacted_slot = index
		
		inventory.add_to_stack(index, 1)
		InventoryCursor.subtract(1)

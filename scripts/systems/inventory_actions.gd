extends Node
class_name InventoryActions

static var _last_interacted_slot: int = -1
static var _last_interacted_inv: Inventory = null

static var _drag_inventory: Inventory = null
static var _drag_item: Item = null
static var _drag_max_stack: int = 0
static var _drag_indices: Array[int] = []

static var _total_drag_pool: int = 0

static func primary_interaction(inventory: Inventory, index: int):
	var slot_stack := inventory.get_slot(index)
	var held := InventoryCursor.get_item_stack()
	
	if not held:
		if slot_stack:
			_take_all(inventory, index)
		return
	
	# Initialize drag session
	_drag_indices = [index]
	_drag_inventory = inventory
	_drag_item = held.item
	_drag_max_stack = held.item.max_stack
	_total_drag_pool = held.quantity
	if slot_stack:
		# Add the first slot quantity to pool if there is a stack in that slot
		_total_drag_pool += slot_stack.quantity

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
	
	_last_interacted_slot = index
	_last_interacted_inv = inventory

static func end_interaction_session():
	_last_interacted_inv = null
	_last_interacted_slot = -1

static func clean_up_drag():
	_drag_indices = []
	_drag_inventory = null
	_drag_item = null
	_drag_max_stack = 0
	
	_total_drag_pool = 0

# --- Helpers ---

static func _end_primary_drag():
	if _drag_indices.is_empty():
		clean_up_drag()
	
	elif _drag_indices.size() == 1:
		_handle_single_place_or_swap(_drag_inventory, _drag_indices[0])
	
	else:
		_distribute_held_stack()
	
	clean_up_drag()

static func _update_primary_drag(inventory: Inventory, index: int):
	if inventory != _drag_inventory or index in _drag_indices:
		return
		
	# Add current slot to the system
	var slot_stack := _drag_inventory.get_slot(index)
	if slot_stack == null or slot_stack.item == _drag_item:
		_drag_indices.append(index)
		
		# Add this slot's items to the total drag pool ONCE
		if slot_stack:
			_total_drag_pool += slot_stack.quantity
		
		_distribute_held_stack()

static func _distribute_held_stack():
	var count := _drag_indices.size()
	if count == 0:
		return
	
	# Compute distribution
	print('total drag pool = ', _total_drag_pool)
	var amount_per_slot := int(_total_drag_pool / count)
	var remainder := _total_drag_pool - amount_per_slot * count
	
	# Cap by max stack
	var max_s := _drag_max_stack
	if amount_per_slot > max_s:
		print('Amount per slot exceded the max stack quantity!')
		# Pass the extra items to the remainder for each item
		remainder += (amount_per_slot - max_s) * count
		# Set the amount per slot the the max/correct quantity
		amount_per_slot = max_s
	
	print('amount per slot: ' + str(amount_per_slot))
	print('remainder: ' + str(remainder))
	print()
	
	# Apply logic to all slots
	for idx in _drag_indices:
		var slot_stack := _drag_inventory.get_slot(idx)
		
		if slot_stack:
			_drag_inventory.set_slot_quantity(idx, amount_per_slot)
		elif not slot_stack:
			_drag_inventory.set_slot(idx, ItemStack.new(_drag_item, amount_per_slot))
	
	# Cursor gets remainder
	if InventoryCursor.is_holding():
		InventoryCursor.set_quantity(remainder)
	else:
		InventoryCursor.set_item_stack(ItemStack.new(_drag_item, remainder))
	
	print('final remainder = ', remainder)
	#print('inventory cursor = ', InventoryCursor.get_item_stack().quantity)
	print()

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
		var new_stack := ItemStack.new(held.item, 1)
		
		inventory.set_slot(index, new_stack)
		InventoryCursor.subtract(1)
	
	elif (slot_stack.item == held.item 
	and slot_stack.quantity < slot_stack.item.max_stack):
		inventory.add_to_stack(index, 1)
		InventoryCursor.subtract(1)

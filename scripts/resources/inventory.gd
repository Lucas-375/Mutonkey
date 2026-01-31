extends Resource
class_name Inventory

signal inventory_changed
signal slot_changed(index: int)

@export var size: int = 27:
	set(value):
		size = value
		slots.resize(size)

var slots: Array[ItemStack] = []

func _init() -> void:
	print(size)
	slots.resize(size)

func is_valid_index(index: int) -> bool:
	return index >= 0 and index < slots.size()

func clear_slot(index: int):
	if not is_valid_index(index):
		return
	_set_slot(index, null)

## Internal method to set a slot's stack and emit signal.
func _set_slot(index: int, new_stack: ItemStack):
	if not is_valid_index(index):
		return
	slots[index] = new_stack
	slot_changed.emit(index)

## Public method to set a slot's stack. Might be extended later.
func set_slot(index: int, new_stack: ItemStack):
	_set_slot(index, new_stack)

## Returns the stack at `index`, or null if invalid.
func get_slot(index: int) -> ItemStack:
	if not is_valid_index(index):
		return null
	return slots[index]

## Returns a deep copy of all slots to prevent external mutation.
func get_slots() -> Array[ItemStack]:
	var copy: Array[ItemStack] = []
	for stack in slots:
		if stack:
			copy.append(stack.duplicate(true))
		else:
			copy.append(null)
	return copy

## Adds up to `amount` items to the stack at `index`.
## Returns the leftover amount that could not fit.
func add_to_stack(index: int, amount: int = 1) -> int:
	var stack := get_slot(index)
	if stack == null:
		return amount

	var space := stack.item.max_stack - stack.quantity
	if space == 0:
		return amount
	
	var to_add = min(space, amount)
	stack.quantity += to_add
	_set_slot(index, stack)
	
	return amount - to_add

## Removes up to `amount` items from the stack at `index`.
## Returns the leftover amount that could not be removed.
func remove_from_stack(index: int, amount: int = 1) -> int:
	var stack := get_slot(index)
	if stack == null:
		return amount
	
	if amount <= stack.quantity:
		stack.quantity -= amount
		_set_slot(index, stack)
		return 0
	
	_set_slot(index, null)
	return amount - stack.quantity

## Swaps the stack of two slots.
func swap_slots(index1: int, index2: int):
	if not is_valid_index(index1) or not is_valid_index(index2):
		return
	if index1 == index2:
		return
	
	var stack1 := get_slot(index1)
	var stack2 := get_slot(index2)
	
	_set_slot(index1, stack2)
	_set_slot(index2, stack1)

## Adds `amount` of `item` to the inventory.
## Returns the leftover amount that could not be added.
func add_item(item:  Item, amount: int = 1) -> int:
	# Try stacking
	for i in range(slots.size()):
		var stack := get_slot(i)
		if stack and stack.item == item and stack.quantity < item.max_stack:
			amount = add_to_stack(i, amount)
			if amount <= 0:
				return 0
	
	# Try creating new stack
	for i in range(slots.size()):
		if get_slot(i) == null:
			var new_stack = ItemStack.new(item)
			var to_add = min(amount, item.max_stack)
			new_stack.quantity = to_add
			_set_slot(i, new_stack)
			amount -= to_add
			if amount <= 0:
				return 0
	
	return amount

## Removes `amount` of `item` from the inventory.
## Returns the leftover amount that could not be removed.
func remove_item(item: Item, amount) -> int:
	for i in range(slots.size()):
		var stack := get_slot(i)
		if stack and stack.item == item:
			amount = remove_from_stack(i, amount)
			if amount <= 0:
				return 0
	
	return amount

func has_item(item: Item, amount: int = 1) -> bool:
	var total := 0
	for stack in slots:
		if stack and stack.item == item:
			total += stack.quantity
			if total >= amount:
				return true
	return false

func find_item_index(item: Item) -> int:
	for i in range(slots.size()):
		var stack := get_slot(i)
		if stack and stack.item == item:
			return i
	return -1

func find_all_indices(item: Item) -> Array[int]:
	var result: Array[int] = []
	for i in range(slots.size()):
		var stack := get_slot(i)
		if stack and stack.item == item:
			result.append(i)
	return result

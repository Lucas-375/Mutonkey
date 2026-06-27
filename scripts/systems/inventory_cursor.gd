extends Node

signal content_changed(new_stack: ItemStack)

@export var _stack: ItemStack = null

## Clears stack to null.
func clear():
	set_item_stack(null)

## Returns the stack.
func get_item_stack() -> ItemStack:
	return _stack

## Returns the stack's quantity.
func get_stack_quantity() -> int:
	return _stack.quantity if is_holding() else 0

## Returns the stack's item.
func get_item() -> Item:
	return _stack.item if is_holding() else null

# Returns how much is left until the stack reaches its max quantity.
func get_space_left() -> int:
	if not is_holding():
		return 0
	return _stack.item.max_stack - _stack.quantity

## Sets the stack to `value`.
func set_item_stack(value: ItemStack):
	if value and value.quantity <= 0:
		return
	_stack = value
	content_changed.emit(_stack)

## Sets the stack from the given values `item` and `quantity`.
func set_stack_from_values(item: Item, quantity: int):
	if item and quantity and quantity <= 0:
		return
	var new_stack := ItemStack.new(item, quantity)
	set_item_stack(new_stack)

## Returns True if the cursor is holding a stack
func is_holding():
	return true if _stack else false

## Returns True if the cursor can accept that item.
## Either if the cursor is empty or both have the same item.
func can_accept(item: Item) -> bool:
	return not is_holding() or item == _stack.item

## Method to set stack to `quantity`.
## Returns how much was added (positive) or removed (negative),
## to achieve the given `quantity`.
func set_quantity(quantity: int) -> int:
	if not _stack:
		return 0
	
	var change = quantity - _stack.quantity
	
	if change > 0:
		add(change)
	if change < 0:
		subtract(abs(change))
	
	return change

## Adds up to `amount` to the stack.
## Returns the leftover that could not fit.
func add(amount: int) -> int:
	if not _stack:
		return amount
	 
	var max_stack := _stack.item.max_stack
	var space := max_stack - _stack.quantity
	
	if space <= 0:
		return amount
	
	var to_add = min(space, amount)
	_stack.quantity += to_add
	set_item_stack(_stack)
	
	# Leftover that did not fit
	return amount - to_add

## Removes up to `amount` from the stack.
## Returns the leftover that could not be removed.
func subtract(amount: int) -> int:
	if not _stack:
		return amount
	
	# Subtract the `amount` and keep remaining stack
	if amount < _stack.quantity:
		_stack.quantity -= amount
		set_item_stack(_stack)
		return 0
	
	# amount >= quantity -> remove everything
	var leftover := amount - _stack.quantity
	clear()
	
	return leftover

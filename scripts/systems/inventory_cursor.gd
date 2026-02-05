extends Node

signal content_changed(new_stack: ItemStack)

@export var _stack: ItemStack = null

## Returns the stack.
func get_item_stack() -> ItemStack:
	return _stack

## Sets the stack to `value`.
func set_item_stack(value: ItemStack):
	_stack = value
	content_changed.emit(_stack)

## Clears stack to null.
func clear():
	set_item_stack(null)

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

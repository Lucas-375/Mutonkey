extends Control
class_name InventorySlot

@export var index: int
@export var inventory: Inventory

var mouse_hovering: bool = false
var right_click_pressed: bool = false

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

func update_slot():
	var stack = inventory.slots[index]
	
	if stack == null:
		$Icon.hide()
		$CountLabel.hide()
		return
	
	if stack.item.display_texture:
		$Icon.show()
		$Icon.texture = stack.item.display_texture
	
	$CountLabel.show()
	$CountLabel.text = str(stack.quantity)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			CursorManager.handle_left_click(inventory, index)
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				CursorManager.right_click_pressed = true
			if not event.pressed:
				CursorManager.right_click_pressed = false

func _process(_delta: float) -> void:
	if mouse_hovering and CursorManager.right_click_pressed:
		CursorManager.handle_right_click(inventory, index)

func on_mouse_entered():
	mouse_hovering = true
	if CursorManager.right_click_pressed:
		CursorManager.handle_right_click(inventory, index)

func on_mouse_exited():
	mouse_hovering = false

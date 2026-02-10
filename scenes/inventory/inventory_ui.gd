extends Control

@onready var grid_container: GridContainer = $GridContainer

@export var inventory: Inventory
@export var columns: int = 8
@export var slot_scene: PackedScene

var _right_click_held := false
var _right_click_timer := 0.0
var _initial_delay := 0.2
var _repeat_rate := 0.08

var _left_click_held := false

var _hovered_index := -1

func _ready() -> void:
	grid_container.columns = columns
	inventory.inventory_changed.connect(on_inventory_changed)
	inventory.slot_changed.connect(on_slot_changed)
	create_slots()
	refresh_all()

func _process(delta: float) -> void:
	if _hovered_index == -1:
		return
	
	_right_click_timer -= delta
	
	if _right_click_held and _right_click_timer <= 0:
		_right_click_timer = _repeat_rate
		InventoryActions.secondary_interaction(inventory, _hovered_index)
	
	if _left_click_held:
		InventoryActions._update_primary_drag(inventory, _hovered_index)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_right_click_held = true
				_right_click_timer = _initial_delay
				if _hovered_index != -1:
					InventoryActions.secondary_interaction(inventory, _hovered_index)
			else:
				_right_click_held = false 
				InventoryActions.end_interaction_session()
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_left_click_held = true
				if _hovered_index != -1:
					InventoryActions.primary_interaction(inventory, _hovered_index)
			else:
				_left_click_held = false
				InventoryActions._end_primary_drag()

func create_slots():
	for i in range(inventory.slots.size()):
		var slot_instance := slot_scene.instantiate() as InventorySlot
		slot_instance.index = i
		slot_instance.inventory = inventory
		
		slot_instance.mouse_entered.connect(func(): _on_slot_hovered(i))
		slot_instance.mouse_exited.connect(func(): _on_slot_unhovered(i))
		
		grid_container.add_child(slot_instance)

func refresh_all():
	for slot: InventorySlot in grid_container.get_children():
		slot.update_slot()

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

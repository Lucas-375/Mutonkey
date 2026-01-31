extends Control

@onready var grid_container: GridContainer = $GridContainer

@export var inventory: Inventory
@export var columns: int = 8
@export var slot_scene: PackedScene

func _ready() -> void:
	grid_container.columns = columns
	inventory.inventory_changed.connect(on_inventory_changed)
	inventory.slot_changed.connect(on_slot_changed)
	create_slots()
	refresh_all()

func create_slots():
	for i in range(inventory.slots.size()):
		print(str(inventory.slots.size()))
		var slot_instance := slot_scene.instantiate() as InventorySlot
		slot_instance.index = i
		slot_instance.inventory = inventory
		grid_container.add_child(slot_instance)

func refresh_all():
	for slot: InventorySlot in grid_container.get_children():
		slot.update_slot()

func refresh_index(index: int):
	if not inventory.is_valid_index(index):
		return
	var slot := grid_container.get_child(index) as InventorySlot
	slot.update_slot()

func on_inventory_changed():
	refresh_all()

func on_slot_changed(index: int):
	refresh_index(index)

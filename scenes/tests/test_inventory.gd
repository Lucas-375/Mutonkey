extends Node

@onready var inventory_ui: Control = $InventoryUI
@onready var add_coin_button: Button = $AddCoinButton
@onready var add_stick_button: Button = $AddStickButton
@onready var toggle_max_button: Button = $ToggleMaxButton
@onready var cursor_item_slot: InventorySlot = $InventorySlot

var max_add := false

func _ready() -> void:
	toggle_max_button.pressed.connect(on_toggle_max_button_pressed)
	add_coin_button.pressed.connect(on_add_coin_button_pressed)
	add_stick_button.pressed.connect(on_add_stick_button_pressed)
	cursor_item_slot.stack = InventoryCursor.get_item_stack()
	_update_toggle_button()

func _process(delta: float) -> void:
	cursor_item_slot.stack = InventoryCursor.get_item_stack()
	cursor_item_slot.update_slot()

func on_toggle_max_button_pressed():
	max_add = not max_add
	_update_toggle_button()

func on_add_stick_button_pressed():
	var stick := ItemDatabase.items[ItemDatabase.ITEM_STICK]
	_add_item(stick)

func on_add_coin_button_pressed():
	var coin := ItemDatabase.items[ItemDatabase.ITEM_COIN]
	_add_item(coin)

func _update_toggle_button():
	toggle_max_button.text = 'Max Add (%s)' % ('ON' if max_add else 'OFF')

func _add_item(item: Item):
	var amount := item.max_stack if max_add else 1
	inventory_ui.inventory.add_item(item, amount)

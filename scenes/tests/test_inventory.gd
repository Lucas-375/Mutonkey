extends Node

@onready var inventory_ui: Control = $InventoryUI
@onready var add_coin_button: Button = $AddCoinButton
@onready var add_stick_button: Button = $AddStickButton
@onready var toggle_max_button: Button = $ToggleMaxButton

var max_add := false

func _ready() -> void:
	toggle_max_button.pressed.connect(on_toggle_max_button_pressed)
	add_coin_button.pressed.connect(on_add_coin_button_pressed)
	add_stick_button.pressed.connect(on_add_stick_button_pressed)
	_update_toggle_button()

func on_toggle_max_button_pressed():
	max_add = not max_add
	_update_toggle_button()

func on_add_stick_button_pressed():
	var stick := ItemDatabase.items[ItemDatabase.ITEM_STICK]
	_add_item(stick)

func on_add_coin_button_pressed():
	var coin := ItemDatabase.items[ItemDatabase.ITEM_COIN]
	_add_item(coin)
	print('coin')

func _update_toggle_button():
	toggle_max_button.text = 'Max Add (%s)' % ('ON' if max_add else 'OFF')

func _add_item(item: Item):
	var amount := item.max_stack if max_add else 1
	print('_add_item called')
	inventory_ui.inventory.add_item(item, amount)

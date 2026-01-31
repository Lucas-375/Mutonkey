extends Resource
class_name ItemStack

@export var item: Item
@export var quantity: int = 1

func _init(_item: Item = null, _quantity: int = 1) -> void:
	item = _item
	quantity = _quantity

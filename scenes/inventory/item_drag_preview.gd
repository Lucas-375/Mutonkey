extends Control


func set_item(item: Item, quantity: int):
	$Icon.texture = item.display_texture
	$CountLabel.text = str(quantity) if quantity > 0 else ''

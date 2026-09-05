extends Control
class_name ItemUIDisplay

@onready var icon: TextureRect = $Icon
@onready var count_label: Label = $CountLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	hide()

func update_display(item: Item, quantity: int):
	if item == null:
		hide()
		icon.texture = null
		count_label.text = ""
		return
	
	show()
	
	icon.texture = item.display_texture
	icon.visible = icon.texture != null

	count_label.text = str(quantity)
	count_label.visible = quantity > 1	

extends Node

const ITEM_STICK = 'stick'
const ITEM_STONE = 'stone'
const ITEM_COIN = 'coin'

## A dictionary mapping item names to their corresponding item resources.
var items: Dictionary[String, Resource] = {
	ITEM_STICK: preload("res://data/items/stick.tres"),
	ITEM_STONE: preload("res://data/items/stone.tres"),
	ITEM_COIN: preload("res://data/items/coin.tres"),
}

## Returns the item resource for the given item_name.
func get_item(item_name: String) -> Item:
	var item = items.get(item_name)
	if item == null:
		push_warning('ItemDatabase: Unknown item_id %s' % item_name)
	return item

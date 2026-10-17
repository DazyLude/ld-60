extends Node2D
class_name Station


signal item_received(item: Item);
signal item_removed;


@export var station_name : String;
@export var hitbox : Area2D;
@export var item_placement : Marker2D;
@export var item_slot : ItemSlot;

var _item : Item;


func _ready() -> void:
	hitbox.owner = self;


func activate() -> void:
	item_slot.activate();


func deactivate() -> void:
	item_slot.deactivate();


func receive_item(item: Item) -> void:
	item.reparent(self);
	item.position = item_placement.position;
	item.show();
	
	item_slot.display_item(item);
	_item = item;
	
	item_received.emit(item);


func has_item() -> bool:
	return _item != null;


func dispense_item() -> Item:
	_item.position = Vector2();
	
	item_slot.clear();
	var t_item := _item;
	_item = null;
	item_removed.emit()
	return t_item;

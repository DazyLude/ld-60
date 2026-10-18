extends Sprite2D
class_name ItemSlot


@export var item_sprite : Sprite2D;


func activate() -> void:
	self.modulate.a = 0.8;


func deactivate() -> void:
	if item_sprite.texture == null:
		self.modulate.a = 0.3;
	else:
		self.modulate.a = 0.0;


func display_item(item: Item) -> void:
	item_sprite.texture = item.item_texture;


func clear() -> void:
	item_sprite.texture = null;

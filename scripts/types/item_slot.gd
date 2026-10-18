extends Sprite2D
class_name ItemSlot


@export var item_sprite : Sprite2D;
@export var ignore_cultist : bool = false;


func activate() -> void:
	self.modulate.a = 0.8;


func deactivate() -> void:
	if item_sprite.texture == null:
		self.modulate.a = 0.3;
	else:
		self.modulate.a = 0.0;


func display_item(item: Item) -> void:
	if item.item_name == "cultist" and not ignore_cultist:
		item_sprite.hide()
	else:
		item_sprite.show()
	
	item_sprite.texture = item.item_texture;


func clear() -> void:
	item_sprite.texture = null;

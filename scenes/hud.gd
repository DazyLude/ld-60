extends CanvasLayer


var active_player : Character;

@export var inventory_display : ItemSlot;
@export var quest_label : Label;


func _process(_delta: float) -> void:
	if active_player != null:
		if active_player.inventory != null:
			inventory_display.display_item(active_player.inventory);
		else:
			inventory_display.clear();



func register_player(player: Character) -> void:
	active_player = player;


func unregister_player(player: Character) -> void:
	active_player = player;

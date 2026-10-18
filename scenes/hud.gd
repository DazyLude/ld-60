extends CanvasLayer


var active_player : Character;
var in_menu : bool;

@export var inventory_display : ItemSlot;
@export var quest_label : Label;


func _process(_delta: float) -> void:
	if active_player != null:
		if active_player.inventory != null:
			inventory_display.display_item(active_player.inventory);
		else:
			inventory_display.clear();


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"exit") and not in_menu:
		get_tree().change_scene_to_file("res://scenes/main/main.tscn");


func register_player(player: Character) -> void:
	active_player = player;


func unregister_player(player: Character) -> void:
	active_player = player;

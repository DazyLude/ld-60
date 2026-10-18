extends Node


var vnplayer := preload("res://scenes/levels/visual_novel_player.tscn");
var main_menu := preload("res://scenes/main/main.tscn");


var main_game_sequence : Array[PackedScene] = [
	preload("res://scenes/dialogues/intro.tscn"),
]


var current_game_sequence : Array[PackedScene] = [];
var current_scene_idx := 0;


func load_game_sequence() -> void:
	current_game_sequence = main_game_sequence;
	current_scene_idx = -1;
	next_scene()


func resume_game_sequence() -> void:
	current_scene_idx -= 1;
	next_scene();


func continue_available() -> bool:
	return not current_game_sequence.is_empty();


func next_scene() -> void:
	current_scene_idx += 1;
	if current_scene_idx >= current_game_sequence.size():
		get_tree().change_scene_to_packed(main_menu);
		return;
	
	var instance := current_game_sequence[current_scene_idx].instantiate();
	if instance is DialogueNode:
		var vnplayer_instance : VNPlayer = vnplayer.instantiate();
		vnplayer_instance.play_dialogue(instance as DialogueNode);
		get_tree().change_scene_to_node(vnplayer_instance);
		vnplayer_instance.finished.connect(next_scene);

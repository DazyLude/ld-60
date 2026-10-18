extends Node


var vnplayer := preload("res://scenes/levels/visual_novel_player.tscn");
var main_menu := preload("res://scenes/main/main.tscn");


var main_game_sequence : Array[PackedScene] = [
	preload("res://scenes/dialogues/intro.tscn"),
	preload("res://scenes/levels/wizard_1.tscn"),
	preload("res://scenes/levels/wizard_2.tscn"),
	preload("res://scenes/levels/wizard_3.tscn"),
	preload("res://scenes/dialogues/part1.tscn"),
	preload("res://scenes/levels/wizard_1.tscn"),
	preload("res://scenes/levels/wizard_2.tscn"),
	preload("res://scenes/levels/wizard_3.tscn"),
	preload("res://scenes/dialogues/part2.tscn"),
	preload("res://scenes/levels/wizard_1.tscn"),
	preload("res://scenes/dialogues/ending.tscn"),
]


var current_game_sequence : Array[PackedScene] = [
	preload("res://scenes/dialogues/ending.tscn"),
];
var current_scene_idx := 0;


var omake_keys : Array[String] = [
	"omake_1_",
]
var omake_cache : Array[String] = omake_keys.duplicate();


func get_unseen_omake(q_actor: VNPlayer.Actor, a_actor: VNPlayer.Actor) -> DialogueNode:
	var key : String;
	if omake_cache.size() > 0:
		key = omake_cache.pick_random();
		omake_cache.erase(key);
	else:
		key = omake_keys.pick_random();
	
	var q := DialogueNode.new();
	q.actor = q_actor;
	q.character_line = key + "q";
	
	var a := DialogueNode.new();
	a.actor = a_actor;
	a.character_line = key + "a";
	
	q.add_child(a);
	
	return q;


func load_game_sequence() -> void:
	HUD.in_menu = false;
	current_game_sequence = main_game_sequence;
	current_scene_idx = -1;
	next_scene()


func resume_game_sequence() -> void:
	HUD.in_menu = false;
	current_scene_idx -= 1;
	next_scene();


func continue_available() -> bool:
	return not current_game_sequence.is_empty();


func next_scene() -> void:
	current_scene_idx += 1;
	if current_scene_idx >= current_game_sequence.size():
		current_game_sequence.clear();
		current_scene_idx = 0;
		get_tree().change_scene_to_packed(main_menu);
		return;
	
	var instance := current_game_sequence[current_scene_idx].instantiate();
	if instance is DialogueNode:
		var vnplayer_instance : VNPlayer = vnplayer.instantiate();
		vnplayer_instance.play_dialogue(instance as DialogueNode);
		vnplayer_instance.finished.connect(next_scene);
		get_tree().change_scene_to_node(vnplayer_instance);
		return;
	
	if instance is Level:
		(instance as Level).finished.connect(next_scene);
		get_tree().change_scene_to_node(instance);
		return;

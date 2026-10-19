extends Node2D
class_name Level

@warning_ignore("unused_signal")
signal finished;
signal shake_finished;

@export var camera : Camera2D;


var vnplayer : VNPlayer;
@export var player_character : VNPlayer.Actor;
@export var searching_engine : VNPlayer.Actor;


func _ready() -> void:
	HUD.show();


func shake() -> void:
	if camera == null:
		return;
	
	var shake_tween := create_tween();
	shake_tween.tween_method(randomize_position, 0.0, SacrificialAltar.appearance_time * 10.0, SacrificialAltar.appearance_time)
	shake_tween.tween_callback(reset_position)
	shake_tween.tween_callback(shake_finished.emit)
	shake_tween.tween_callback(shake_tween.kill);


var prev_position := -1.0;
func randomize_position(time: float) -> void:
	if  time - prev_position >= 1.0:
		prev_position = time;
		
		var rand_x := randf() - 0.5;
		var rand_y := randf() - 0.5;
		
		position = Vector2(20.0, 50.0) * Vector2(rand_x, rand_y);


func reset_position() -> void:
	position = Vector2();


func initialize_local_dialogue_player() -> void:
	var canvas_layer := CanvasLayer.new();
	canvas_layer.layer = 1;
	
	vnplayer = Gamestate.vnplayer.instantiate();
	vnplayer.just_text_box();
	canvas_layer.add_child(vnplayer);
	
	add_child(canvas_layer);


func play_dialogue(dialogue: DialogueNode) -> void:
	if vnplayer == null:
		initialize_local_dialogue_player();
	
	vnplayer.play_dialogue(dialogue);


func play_omake() -> void:
	HUD.active_player.process_mode = Node.PROCESS_MODE_DISABLED;
	
	var omake := Gamestate.get_unseen_omake(
		player_character, searching_engine
	);
	
	play_dialogue(omake);
	vnplayer.play_next();
	vnplayer.finished.connect(finished.emit);

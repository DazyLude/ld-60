extends Node2D
class_name Level

@warning_ignore("unused_signal")
signal finished;

@export var camera : Camera2D;


func _ready() -> void:
	HUD.show();


func shake() -> void:
	if camera == null:
		return;
	
	var shake_tween := create_tween();
	shake_tween.tween_method(randomize_position, 0.0, SacrificialAltar.appearance_time * 10.0, SacrificialAltar.appearance_time)
	shake_tween.tween_callback(reset_position)
	shake_tween.tween_callback(shake_tween.kill);


var prev_position := -1.0;
func randomize_position(time: float) -> void:
	if  time - prev_position >= 1.0:
		prev_position = time;
		
		var rand_x := randf() - 0.5;
		var rand_y := randf() - 0.5;
		
		print(Vector2(rand_x, rand_y))
		position = Vector2(20.0, 50.0) * Vector2(rand_x, rand_y);


func reset_position() -> void:
	position = Vector2();

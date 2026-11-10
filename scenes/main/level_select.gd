extends TextureRect
class_name LevelSelect


signal exit;


@export var button_to_levels : Dictionary[BaseButton, PackedScene] = {};
@export var button_to_main_sequence_levels : Dictionary[BaseButton, int] = {};


@export var bonus_root : Control;
@export var quit_button : BaseButton;


func _ready() -> void:
	quit_button.pressed.connect(exit.emit)
	
	for button in button_to_levels:
		var scene := button_to_levels[button];
		button.pressed.connect(play_level.bind(scene));
	
	for button in button_to_main_sequence_levels:
		var idx := button_to_main_sequence_levels[button];
		button.pressed.connect(play_main_sequence_level.bind(idx));


func play_level(level: PackedScene) -> void:
	var level_array : Array[PackedScene] = [level];
	Gamestate.skip_to_level_select = true;
	Gamestate.current_game_sequence = level_array;
	Gamestate.resume_game_sequence();


func play_main_sequence_level(idx: int) -> void:
	Gamestate.skip_to_level_select = true;
	Gamestate.load_game_sequence(idx);

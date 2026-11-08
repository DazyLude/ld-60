extends TextureRect
class_name LevelSelect


signal exit;


@export var button_to_levels : Dictionary[BaseButton, PackedScene] = {};
@export var bonus_root : Control;
@export var quit_button : BaseButton;


func _ready() -> void:
	quit_button.pressed.connect(exit.emit)
	
	for button in button_to_levels:
		button.pressed.connect(play_level.bind(button_to_levels[button]));


func update() -> void:
	bonus_root.visible = Settings.game_finished;


func play_level(level: PackedScene) -> void:
	var level_array : Array[PackedScene] = [level];
	Gamestate.skip_to_level_select = true;
	Gamestate.current_game_sequence = level_array;
	Gamestate.resume_game_sequence();

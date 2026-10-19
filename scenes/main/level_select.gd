extends TextureRect


@export var button_to_levels : Dictionary[BaseButton, PackedScene] = {};
@export var bonus_root : Control;


func _ready() -> void:
	bonus_root.visible = Settings.game_finished;
	
	for button in button_to_levels:
		button.pressed.connect(play_level.bind(button_to_levels[button]));


func play_level(level: PackedScene) -> void:
	var level_array : Array[PackedScene] = [level];
	Gamestate.current_game_sequence = level_array;
	Gamestate.resume_game_sequence();

extends Control


@export var start_game : BaseButton;
@export var continue_game : BaseButton;
@export var level_select : BaseButton;
@export var volume_slider : HSlider;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HUD.hide();
	start_game.pressed.connect(Gamestate.load_game_sequence);
	continue_game.pressed.connect(Gamestate.resume_game_sequence);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Control


@export var start_game : BaseButton;
@export var continue_game : BaseButton;
@export var level_select : BaseButton;
@export var volume_slider : HSlider;

@export var next_lang : BaseButton;
@export var prev_lang : BaseButton;

@export var label : Label;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HUD.hide();
	start_game.pressed.connect(Gamestate.load_game_sequence);
	continue_game.pressed.connect(Gamestate.resume_game_sequence);
	
	next_lang.pressed.connect(switch_language);
	prev_lang.pressed.connect(switch_language);
	
	update_title_label();


func update_title_label() -> void:
	var current_locale := TranslationServer.get_locale();
	
	match current_locale:
		"en_US":
			label.hide()
		_:
			label.show()




func switch_language() -> void:
	var current_locale := TranslationServer.get_locale();
	
	match current_locale:
		"en_US":
			TranslationServer.set_locale("ru");
		"ru":
			TranslationServer.set_locale("en_US");
	
	update_title_label();

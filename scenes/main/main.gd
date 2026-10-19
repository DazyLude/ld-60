extends Control


@export var start_game : BaseButton;
@export var continue_game : BaseButton;
@export var level_select : BaseButton;
@export var from_level_select : BaseButton;
@export var volume_slider : HSlider;

@export var next_lang : BaseButton;
@export var prev_lang : BaseButton;

@export var label : Label;

@export var level_select_root : Control;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HUD.hide();
	HUD.in_menu = true;
	
	BGMPlayer.change_track(BGMPlayer.MusicID.Jazz)
	
	level_select_root.hide();
	Settings.load_state();
	volume_slider.value = Settings.volume;
	
	start_game.pressed.connect(Gamestate.load_game_sequence);
	continue_game.pressed.connect(Gamestate.resume_game_sequence);
	
	volume_slider.value_changed.connect(_on_volume_slider_change)
	next_lang.pressed.connect(switch_language);
	prev_lang.pressed.connect(switch_language);
	
	level_select.pressed.connect(_on_level_select_pressed);
	from_level_select.pressed.connect(_on_back_from_level_select_pressed);
	
	update_title_label();
	
	continue_game.visible = Gamestate.continue_available();


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
			Settings.locale = "ru";
		_, "ru":
			Settings.locale = "en_US";
	
	update_title_label();
	Settings.save_state();


func _on_volume_slider_change(v: float) -> void:
	Settings.volume = v;
	Settings.save_state();


func _on_level_select_pressed() -> void:
	level_select_root.show();
	level_select_root.update();


func _on_back_from_level_select_pressed() -> void:
	level_select_root.hide();

extends Node


const MUSIC_BUS_NAME := &"Music"
const SFX_BUS_NAME := &"FX"


var volume : float = 0.5 :
	set(v):
		volume = v;
		var master_idx := AudioServer.get_bus_index(&"Master");
		AudioServer.set_bus_volume_linear(master_idx, v);

var game_finished : bool = false;

var locale : String = "en_US":
	set(v):
		locale = v;
		TranslationServer.set_locale(v);

var cleared_levels : Array[String] = []


func save_state() -> void:
	var state : Array = [volume, game_finished, locale, cleared_levels];
	var string := var_to_str(state);
	
	var file := FileAccess.open("user://settings.dat", FileAccess.WRITE);
	file.store_string(string);


func load_state() -> void:
	if FileAccess.file_exists("user://settings.dat"):
		var file := FileAccess.open("user://settings.dat", FileAccess.READ);
		var string := file.get_as_text();
		var state : Array = str_to_var(string);
		
		print(state);
		
		var try_volume : Variant = state.get(0);
		if try_volume != null and typeof(try_volume) == TYPE_FLOAT:
			volume = try_volume;
		
		var try_finished_flag : Variant = state.get(1);
		if try_finished_flag != null and typeof(try_finished_flag) == TYPE_BOOL:
			game_finished = try_finished_flag;
		
		var try_locale : Variant = state.get(2);
		if try_locale != null and typeof(try_locale) == TYPE_STRING:
			locale = try_locale;
		
		var try_cleared_levels : Variant = state.get(3);
		if try_cleared_levels != null and typeof(try_cleared_levels) == TYPE_ARRAY:
			cleared_levels = try_cleared_levels;


func reset_state() -> void:
	volume = 0.5;
	game_finished = false;
	locale = "en_US";
	cleared_levels = Array([], TYPE_STRING, &"", null);
	
	save_state();


func reset_progress() -> void:
	game_finished = false;
	cleared_levels = Array([], TYPE_STRING, &"", null);

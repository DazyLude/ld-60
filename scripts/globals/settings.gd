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


func save_state() -> void:
	var state : Array = [volume, game_finished, locale];
	var string := var_to_str(state);
	
	var file := FileAccess.open("user://settings.dat", FileAccess.WRITE);
	file.store_string(string);


func load_state() -> void:
	if FileAccess.file_exists("user://settings.dat"):
		var file := FileAccess.open("user://settings.dat", FileAccess.READ);
		var string := file.get_as_text();
		var state : Array = str_to_var(string);
		
		print(state);
		
		volume = state[0];
		game_finished = state[1];
		locale = state[2];


func reset_state() -> void:
	volume = 0.5;
	game_finished = false;
	locale = "en_US";
	
	save_state();

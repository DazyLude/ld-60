extends Node

## Prefixes:
## Music - music
## Am - ambient
## FX - sound effects
## UX - mouse and UI feedback sounds
enum MusicID {
	None = 0,
	PaleorockClassic,
	Nature,
	Jazz,
	Wizard,
	Vampire,
}

enum EffectID {
	None = 0,
	Bonk = 1,
	
	GemDrop,
	GemInsert,
	GemTake,
	
	BookTake,
	
	Ritual,
}


const uid_per_music_id : Dictionary[MusicID, String] = {
	MusicID.None: "",
	MusicID.PaleorockClassic: "res://assets/music/finale_music.wav",
	MusicID.Nature: "res://assets/music/nature.wav",
	MusicID.Jazz: "res://assets/music/jazz.wav",
	MusicID.Wizard: "res://assets/music/wizardlvl_music.wav",
	MusicID.Vampire: "res://assets/music/vampirelvl_music.wav",
}


const uid_per_sfx_id : Dictionary[EffectID, String] = {
	EffectID.None: "",
	EffectID.Bonk: "res://assets/sfx/stone_hit.wav",
	EffectID.GemDrop: "res://assets/sfx/gem_drop.ogg",
	EffectID.GemInsert: "res://assets/sfx/gem_insert.ogg",
	EffectID.GemTake: "res://assets/sfx/gem_take.ogg",
	EffectID.BookTake: "res://assets/sfx/book.ogg",
	
	EffectID.Ritual: "res://assets/sfx/ritual.ogg",
}


const TRANSITION_TIME : float = 2.0;


var current_track : MusicID = MusicID.None;
var last_player : AudioStreamPlayer;
var player_tweens : Dictionary[AudioStreamPlayer, Tween];


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	# check file paths


func add_player(bus := Settings.MUSIC_BUS_NAME) -> AudioStreamPlayer:
	var new_player := AudioStreamPlayer.new();
	new_player.bus = bus;
	
	player_tweens[new_player] = null;
	add_child(new_player);
	
	return new_player;


func remove_player(player: AudioStreamPlayer) -> void:
	if player_tweens[player]:
		player_tweens[player].kill();
	
	player_tweens.erase(player);
	remove_child(player);
	player.queue_free();


func change_track(new_track: MusicID) -> void:
	if new_track == current_track:
		return;
	
	current_track = new_track;
	
	if last_player != null:
		if player_tweens[last_player]:
			player_tweens[last_player].kill();
		
		var lp_tween := create_tween();
		lp_tween.set_trans(Tween.TRANS_QUINT);
		player_tweens[last_player] = lp_tween;
		
		lp_tween.tween_property(last_player, ^"volume_linear", 0.0, TRANSITION_TIME);
		lp_tween.tween_callback(remove_player.bind(last_player));
	
	if new_track == MusicID.None:
		return;
	
	var new_player := add_player(Settings.MUSIC_BUS_NAME);
	last_player = new_player;
	
	var stream : AudioStream = ResourceLoader.load(uid_per_music_id[new_track]);
	_make_looped(stream);
	
	new_player.stream = stream;
	new_player.volume_linear = 0.0;
	
	var np_tween := create_tween();
	np_tween.set_trans(Tween.TRANS_QUINT);
	player_tweens[new_player] = np_tween;
	
	np_tween.tween_property(new_player, ^"volume_linear", 1.0, TRANSITION_TIME);
	new_player.play();


func play_one_off(sound: EffectID) -> void:
	if sound == EffectID.None:
		#push_warning("BGMPlayer warning: trying to play SoundId.None")
		return;
	
	var player := add_player(Settings.SFX_BUS_NAME);
	var stream := ResourceLoader.load(uid_per_sfx_id[sound]);
	player.stream = stream;
	player.play();
	player.finished.connect(remove_player.bind(player));



var looped_sfx_players : Dictionary[int, AudioStreamPlayer] = {};
var looped_sfx_play_counts : Dictionary[int, int] = {};
var last_id : int = 0;
const DEFAUL_LOOP_LIMIT := 128;

## call this function to play a SoundID stream in a looped fashion.[br]
## [method play_looped] returns an integer.[br]
## This integer should be used to call [method stop_looped]
## to stop the looping sound from playing
func play_looped(sound: EffectID, loop_limit: int = -1) -> int:
	if sound == EffectID.None:
		#push_warning("BGMPlayer warning: trying to play SoundId.None looped")
		return -1;
	
	last_id += 1
	
	var player := add_player(Settings.SFX_BUS_NAME);
	looped_sfx_players[last_id] = player;
	looped_sfx_play_counts[last_id] = 0;
	
	var stream : AudioStream = ResourceLoader.load(uid_per_sfx_id[sound]);
	_make_looped(stream);
	player.stream = stream;
	
	player.play();
	player.finished.connect(_increment_play_count.bind(last_id, loop_limit));
	
	return last_id;


func _increment_play_count(id: int, loop_limit: int, soundID: EffectID) -> void:
	looped_sfx_play_counts[id] += 1;
	if loop_limit == -1:
		loop_limit = DEFAUL_LOOP_LIMIT;
	
	if looped_sfx_play_counts[id] >= loop_limit:
		push_warning("BGMPlayer warning: sound (%s) loop limit (%s) reached." % [loop_limit, soundID])
		_stop_looped(id)


## call this function to stop a looped sfx player.[br]
func stop_looped(looped_id: int) -> void:
	if looped_id == -1:
		return;
	
	if not looped_sfx_players.has(looped_id):
		return;
	
	_stop_looped(looped_id);


func _stop_looped(looped_id: int) -> void:
	var player := looped_sfx_players[looped_id];
	
	if player != null:
		player.stop();
		remove_player(player);
	
	looped_sfx_players.erase(looped_id);
	looped_sfx_play_counts.erase(looped_id);


func stop_all_looped() -> void:
	for id in looped_sfx_players:
		_stop_looped(id);


func _make_looped(stream: AudioStream) -> void:
	@warning_ignore_start("unsafe_property_access")
	match stream: # set up looping
		_ when stream is AudioStreamWAV: 
			stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD;
			stream.loop_end = stream.get_length() * stream.mix_rate;
		_ when stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
			stream.loop = true;
		null:
			push_warning(
				"BGMPlayer warning: trying to loop null stream"
			);
		_:
			# other cases not implemented
			push_warning(
				"BGMPlayer warning: unexpected music stream type, looping won't work"
			);
	@warning_ignore_restore("unsafe_property_access")

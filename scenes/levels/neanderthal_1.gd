extends Level


@export var stone : Station;

@export var player : Character;
@export var doll1 : Character;
@export var doll2 : Character;

var p_start_idx := 2;
var doll_1_start_idx := 4;
var doll_2_start_idx := 7;

var doll1_tween : Tween;
var doll2_tween : Tween;
var p_tween : Tween;

@export var route : Array[Marker2D];

const walkup_length : float = 3.0;
const segment_length : float = 1.5;


func _ready() -> void:
	super();
	HUD.quest_label.text = "quest_neanderthal";
	stone.item_received.connect(start_cutscene);
	doll1.assume_direct_control = true;
	doll2.assume_direct_control = true;


func start_cutscene(_i: Item) -> void:
	HUD.hide()
	
	stone.hitbox.monitorable = false;
	stone.deactivate();
	
	BGMPlayer.play_one_off(BGMPlayer.EffectID.Bonk);
	
	player.assume_direct_control = true;
	
	doll1.explode()
	doll1.show()
	
	doll2.explode()
	doll2.show()
	
	p_tween = create_tween();
	doll1_tween = create_tween();
	doll2_tween = create_tween();
	
	p_tween.tween_interval(walkup_length)
	doll1_tween.tween_interval(walkup_length)
	doll2_tween.tween_interval(walkup_length)
	
	p_tween.tween_callback(BGMPlayer.change_track.bind(BGMPlayer.MusicID.PaleorockClassic))
	
	p_tween.tween_callback(func() -> void: player.force_plushing = true);
	doll1_tween.tween_callback(func() -> void: doll2.force_plushing = true);
	doll2_tween.tween_callback(func() -> void: doll1.force_plushing = true);
	
	p_tween.tween_property(
		player, ^"position", get_ith_position(p_start_idx), walkup_length);
	doll1_tween.tween_property(
		doll1, ^"position", get_ith_position(doll_1_start_idx), walkup_length);
	doll2_tween.tween_property(
		doll2, ^"position", get_ith_position(doll_2_start_idx), walkup_length);
	
	for i in 10:
		p_tween.tween_property(
			player, ^"position", get_ith_position(p_start_idx + i + 1), segment_length);
		doll1_tween.tween_property(
			doll1, ^"position", get_ith_position(doll_1_start_idx + i + 1), segment_length);
		doll2_tween.tween_property(
			doll2, ^"position", get_ith_position(doll_2_start_idx + i + 1), segment_length);
	
	p_tween.tween_callback(_on_end)


func _on_end() -> void:
	BGMPlayer.change_track(BGMPlayer.MusicID.None);
	
	if vnplayer == null:
		initialize_local_dialogue_player();
	
	vnplayer.just_text_box();
	vnplayer.text_box.hide();
	
	finished.emit();


func get_ith_position(i: int) -> Vector2:
	i = wrapi(i, 0, route.size())
	return route[i].position;

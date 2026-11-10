extends Level


@export var cross_gem : ColoredGem;
@export var circle_gem : ColoredGem;


@export var stand : Barrier;
@export var gem_spawn_location : Marker2D;


@export var board : Array[Station] = [];


func _ready() -> void:
	super()
	BGMPlayer.change_track(BGMPlayer.MusicID.Wizard);
	HUD.quest_label.text = "quest_wizard_3";
	stand.book_taken.connect(play_omake);


func spawn_free_gem() -> void:
	pass;


func open_reset_chamber() -> void:
	pass;


func open_draw_chamber() -> void:
	pass;


func reset() -> void:
	pass;
	

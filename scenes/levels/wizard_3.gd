extends Level


@export var stand : Barrier;


func _ready() -> void:
	super()
	BGMPlayer.change_track(BGMPlayer.MusicID.Wizard);
	HUD.quest_label.text = "quest_wizard_3";
	stand.book_taken.connect(play_omake);

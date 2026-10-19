extends Level


@export var sacrificial : SacrificialAltar


func _ready() -> void:
	super()
	HUD.quest_label.text = "quest_vampire";
	BGMPlayer.change_track(BGMPlayer.MusicID.Vampire);
	
	sacrificial.sacrifice_made.connect(_on_successful_sacrifice);


func _on_successful_sacrifice() -> void:
	shake()
	await shake_finished;
	await get_tree().create_timer(0.5).timeout;
	play_omake();

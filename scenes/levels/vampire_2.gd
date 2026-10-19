extends Level


@export var sacrificial : SacrificialAltar


func _ready() -> void:
	super()
	HUD.quest_label.text = "quest_vampire";
	
	sacrificial.sacrifice_made.connect(shake);


func _on_successful_sacrifice() -> void:
	shake()
	await shake_finished;
	play_omake();

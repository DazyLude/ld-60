extends Level


@export var barrier : Barrier;


func _ready() -> void:
	super()
	HUD.quest_label.text = "quest_wizard_2";
	barrier.book_taken.connect(play_omake);

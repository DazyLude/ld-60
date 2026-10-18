extends Level


@export var barrier : Barrier;


func _ready() -> void:
	HUD.quest_label.text = "quest_wizard_3";
	barrier.book_taken.connect(finished.emit);

extends Level


@export var grimoire_stand : Station;


func _ready() -> void:
	super();
	HUD.quest_label.text = "quest_wizard_1";
	grimoire_stand.item_removed.connect(play_omake);

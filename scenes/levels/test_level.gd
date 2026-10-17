extends Level


@export var stone : Station;
@export var target_stick : Item;


func _ready() -> void:
	stone.item_received.connect(check_wincon);


func check_wincon(item: Item) -> void:
	if item == target_stick:
		print("you won!");

extends Level


@export var stone : Station;
@export var target_stick : Item;

@export var book_holder : Station;


func _ready() -> void:
	stone.item_received.connect(check_wincon);
	book_holder.item_removed.connect(pick_book_to_win);


func check_wincon(item: Item) -> void:
	if item == target_stick:
		print("you won! by rock and stone");


func pick_book_to_win() -> void:
	print("you won! by book");

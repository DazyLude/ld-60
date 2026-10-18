extends Level


@export var stone : Station;
@export var target_stick : Item;

@export var book_holder : Station;
@export var sacrificial_stone : SacrificialAltar


func _ready() -> void:
	super();
	stone.item_received.connect(check_wincon);
	book_holder.item_removed.connect(pick_book_to_win);
	sacrificial_stone.sacrifice_made.connect(shake);


func check_wincon(item: Item) -> void:
	if item == target_stick:
		print("you won! by rock and stone");


func pick_book_to_win() -> void:
	print("you won! by book");

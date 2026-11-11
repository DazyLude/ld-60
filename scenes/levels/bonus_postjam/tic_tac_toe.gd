extends Level


@export var cross_gem : Array[ColoredGem];
@export var circle_gem : Array[ColoredGem];
@export var gem_spawn_location : Marker2D;
@export var board : Array[Station] = [];
var _turn_n : int = 0;

@export var stand : Barrier;
var board_state : Array[int] = [
	0, 0, 0,
	0, 0, 0,
	0, 0, 0,
]

var node_tweens : Dictionary[Node2D, Tween] = {};

@export var movement_triggers : Dictionary[Node2D, MovementTriggerData] = {};
var _starting_positions : Dictionary[Node2D, Vector2];

@export var reset_chamber_door : Node2D;
@export var key_chamber_door : Node2D;
@export var victory_chamber_door : Node2D;

@export var knife : Item;
@export var knife_respawn_position : Marker2D;


@export var smoke1 : Sprite2D;
var _smoke_tween_1 : Tween;
@export var smoke2 : Sprite2D;
var _smoke_tween_2 : Tween;


@export var reset_altar : SacrificialAltar;


var owo_banter : Array[String] = ["owo_banter_1", "owo_banter_2", "owo_banter_3"];
var owo_wins := "owo_wins";
var owo_draws := "owo_draws";
var owo_loses := "owo_loses";
@export var banter_box : Sign;
@export var banter_text : RichTextLabel;


func _ready() -> void:
	super()
	BGMPlayer.change_track(BGMPlayer.MusicID.Wizard);
	HUD.quest_label.text = "quest_wizard_3";
	stand.book_taken.connect(play_omake);
	
	for node in movement_triggers:
		_starting_positions[node] = node.position;
	
	for station in board:
		station.item_received.connect(_accept_gem.bind(station))
	
	smoke1.hide()
	smoke2.hide()
	
	reset_altar.sacrifice_made.connect(reset);
	
	reset();


func spawn_free_gem() -> void:
	@warning_ignore("integer_division")
	var gem_i := _turn_n / 2;
	cross_gem[gem_i].show();
	cross_gem[gem_i].unmark_taken();
	cross_gem[gem_i].global_position = gem_spawn_location.global_position;


func open_reset_chamber() -> void:
	var trigger_data := movement_triggers[reset_chamber_door];
	var to := trigger_data.movement_delta;
	var time := trigger_data.movement_time;
	move_node(reset_chamber_door, to, time);


func open_key_chamber() -> void:
	var trigger_data := movement_triggers[key_chamber_door];
	var to := trigger_data.movement_delta;
	var time := trigger_data.movement_time;
	move_node(key_chamber_door, to, time);


func open_victory_chamber() -> void:
	var trigger_data := movement_triggers[victory_chamber_door];
	var to := trigger_data.movement_delta;
	var time := trigger_data.movement_time;
	move_node(victory_chamber_door, to, time);


func _accept_gem(item: Item, station: GemHolder) -> void:
	if item is ColoredGem:
		var gem := item as ColoredGem
		_turn_n += 1;
		station.disable();
		
		var gem_type : int = 1;
		if gem.type == ColoredGem.Type.ONYX:
			gem_type = -1;
		
		var station_idx := board.find(station)
		board_state[station_idx] = gem_type;
		
		var green_light := check_win();
		
		if not green_light:
			return;
		
		if _turn_n % 2 == 1:
			owo_think();
		else:
			spawn_free_gem();
	
	if item.item_name == "knife":
		station.dispense_item()
		respawn_knife();
	
	if item.item_name == "cultist":
		station.dispense_item();
		var cultist := item as NonPlayerCharacter;
		cultist.sacrifice(true);
	


func reset() -> void:
	_turn_n = 0;
	for station in board:
		if station._item != null:
			var item := station.dispense_item();
			item.reparent(self)
			station.enable();
			station.item_slot.deactivate();
	
	for gem in cross_gem:
		gem.hide();
		gem.mark_taken();
	
	for gem in circle_gem:
		gem.hide();
		gem.mark_taken();
	
	for i in board_state.size():
		board_state[i] = 0;
	
	spawn_free_gem();


var hide_tween : Tween;
func owo_think() -> void:
	var free_slots : Array[int];
	for idx in board_state.size():
		if board_state[idx] == 0:
			free_slots.push_back(idx);
	
	if free_slots.is_empty():
		_on_draw();
		return;
	
	banter_text.text = owo_banter.pick_random();
	banter_box.activate();
	hide_owo_box_later(4.0);
	await get_tree().create_timer(1.5).timeout;
	
	var ws := get_win_square();
	if ws != -1:
		owo_place_gem(ws);
		return;
	
	var ls := get_lose_square();
	if ls != -1:
		owo_place_gem(ls);
		return;
	
	if free_slots.has(4):
		owo_place_gem(4);
		return;
	else:
		var choice : int = free_slots.pick_random()
		owo_place_gem(choice);


func owo_place_gem(at: int) -> void:
	@warning_ignore("integer_division")
	var gem_i := _turn_n / 2;
	circle_gem[gem_i].show();
	circle_gem[gem_i].mark_taken()
	board[at].receive_item(circle_gem[gem_i])
	play_smokescreen(circle_gem[gem_i], 0)


func respawn_knife() -> void:
	#play_smokescreen(knife, 0)
	knife.unmark_taken();
	knife.reparent(self);
	knife.global_position = knife_respawn_position.global_position;
	play_smokescreen(knife, 1);


func get_sum_arr() -> Array[int]:
	# check rows
	var sum_r1 := board_state[0] + board_state[1] + board_state[2];
	var sum_r2 := board_state[3] + board_state[4] + board_state[5];
	var sum_r3 := board_state[6] + board_state[7] + board_state[8];
	
	# check columns
	var sum_c1 := board_state[0] + board_state[3] + board_state[6];
	var sum_c2 := board_state[1] + board_state[4] + board_state[7];
	var sum_c3 := board_state[2] + board_state[5] + board_state[8];
	
	# check diagonals
	var sum_d1 := board_state[0] + board_state[4] + board_state[8];
	var sum_d2 := board_state[2] + board_state[4] + board_state[6];
	
	var sum_arr : Array[int] = [
		sum_r1, sum_r2, sum_r3,
		sum_c1, sum_c2, sum_c3,
		sum_d1, sum_d2
	]
	
	return sum_arr;


func check_win() -> bool:
	var sum_arr := get_sum_arr();
	
	if sum_arr.any(func(s: int) -> bool: return s == 3):
		_on_win();
		return false;
	
	if sum_arr.any(func(s: int) -> bool: return s == -3):
		_on_loss();
		return false;
	
	return true;


func get_win_square() -> int:
	var sum_arr := get_sum_arr();
	
	match sum_arr.find(-2): # find a winning line
		0: # row 012
			return get_empty_square_idx([0, 1, 2])
		1: # row 345
			return get_empty_square_idx([3, 4, 5])
		2: # row 678
			return get_empty_square_idx([6, 7, 8])
		3: # column 036
			return get_empty_square_idx([0, 3, 6])
		4: # column 147
			return get_empty_square_idx([1, 4, 7])
		5: # column 258
			return get_empty_square_idx([2, 5, 8])
		6: # diagonal 048
			return get_empty_square_idx([0, 4, 8])
		7: # diagonal 246
			return get_empty_square_idx([2, 4, 6])
	
	return -1;


func get_lose_square() -> int:
	var sum_arr := get_sum_arr();
	
	match sum_arr.find(2): # find a losing line
		0: # row 012
			return get_empty_square_idx([0, 1, 2])
		1: # row 345
			return get_empty_square_idx([3, 4, 5])
		2: # row 678
			return get_empty_square_idx([6, 7, 8])
		3: # column 036
			return get_empty_square_idx([0, 3, 6])
		4: # column 147
			return get_empty_square_idx([1, 4, 7])
		5: # column 258
			return get_empty_square_idx([2, 5, 8])
		6: # diagonal 048
			return get_empty_square_idx([0, 4, 8])
		7: # diagonal 246
			return get_empty_square_idx([2, 4, 6])
	
	return -1;


func get_empty_square_idx(from: Array[int]) -> int:
	for idx in from:
		if board_state[idx] == 0:
			return idx;
	
	return -1;


func _on_loss() -> void:
	open_reset_chamber()
	banter_text.text = owo_wins;
	banter_box.activate();
	hide_owo_box_later(8.0);


func _on_win() -> void:
	open_victory_chamber()
	banter_text.text = owo_loses;
	banter_box.activate();
	hide_owo_box_later(8.0);


func _on_draw() -> void:
	open_key_chamber()
	banter_text.text = owo_draws;
	banter_box.activate();
	hide_owo_box_later(8.0);


func hide_owo_box_later(time: float) -> void:
	if hide_tween:
		hide_tween.kill()
	
	hide_tween = create_tween();
	hide_tween.tween_interval(time)
	hide_tween.tween_callback(banter_box.deactivate);


func _reset_position(node: Node2D, trigger_data: MovementTriggerData) -> void:
	var starting_position := _starting_positions[node];
	if node.position == starting_position:
		return;
	
	move_node(
		node,
		starting_position,
		trigger_data.movement_time
	)


func move_node(node: Node2D, where: Vector2, speed: float = 1.0) -> void:
	var tween := get_new_node_tween(node);
	BGMPlayer.play_one_off(BGMPlayer.EffectID.DissapearanceBarrierSuzumia);
	tween.tween_property(node, ^"position", where, speed)


func get_new_node_tween(node: Node2D) -> Tween:
	var node_tween : Tween = node_tweens.get(node);
	if node_tween:
		node_tween.kill();
	
	node_tween = create_tween();
	node_tweens[node] = node_tween;
	return node_tween;


func play_smokescreen(over: Node2D, idx: int) -> void:
	if idx == 0:
		if _smoke_tween_1:
				_smoke_tween_1.kill();
		
		_smoke_tween_1 = create_tween();
		smoke1.global_position = over.global_position;
		animate(_smoke_tween_1, smoke1);
	
	if idx == 1:
		if _smoke_tween_2:
				_smoke_tween_2.kill();
		
		_smoke_tween_2 = create_tween();
		smoke2.global_position = over.global_position;
		animate(_smoke_tween_2, smoke2);


func animate(tween: Tween, cloud: Sprite2D) -> void:
	var random_rotation := randf() * 2.0 * PI;
	var explosion_time := 0.05;
	var dissipation_time := 0.2;
	
	cloud.self_modulate = Color(1, 1, 1, 0.5)
	cloud.scale = Vector2(0.5, 0.5)
	cloud.rotation = random_rotation - 0.1;
	cloud.show();
	
	# explosion
	tween.tween_property(
		cloud, ^"self_modulate", Color(1, 1, 1, 1.0), explosion_time)
	tween.parallel().tween_property(
		cloud, ^"scale", Vector2(1, 1), explosion_time)
	tween.parallel().tween_property(
		cloud, ^"rotation", random_rotation, explosion_time)
	
	# dissipation
	tween.tween_property(
		cloud, ^"self_modulate", Color(1, 1, 1, 0.2), dissipation_time)
	tween.parallel().tween_property(
		cloud, ^"scale", Vector2(1.2, 1.2), dissipation_time)
	tween.parallel().tween_property(
		cloud, ^"rotation", random_rotation + 0.2, dissipation_time)
	
	# hide
	tween.tween_callback(cloud.hide);

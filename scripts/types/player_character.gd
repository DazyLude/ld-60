extends CharacterBody2D
class_name Character


@export var inventory : Item;
@export var interaction_hitbox : Area2D;
@export var sprite : Sprite2D;
@export var carried_item_position : Marker2D;

@export var speed : float = 400;
@export var smoke_cloud : Sprite2D;


var assume_direct_control : bool = false;
var force_plushing : bool = false;


var _stored_movement := Vector2()
var plush_tween : Tween;


var overlapping : Dictionary[Area2D, Node2D] = {};
var _previously_activated : Node2D;


func _ready() -> void:
	interaction_hitbox.area_entered.connect(_add_area)
	interaction_hitbox.area_exited.connect(_remove_area)
	HUD.register_player(self);


func _input(event: InputEvent) -> void:
	if assume_direct_control:
		return;
	
	if event.is_action_pressed(&"action"):
		try_use_something();
	
	if event.is_action_released(&"cancel"):
		try_drop_something();


func _process(_delta: float) -> void:
	if _stored_movement != Vector2() and plush_tween == null:
		start_plushing();
		_stored_movement = Vector2();
	
	if assume_direct_control and force_plushing and plush_tween == null:
		start_plushing();
	
	var closest := get_closest();
	if closest != _previously_activated:
		deactivate_something(_previously_activated);
		activate_something(closest);
		_previously_activated = closest;


func _physics_process(_delta: float) -> void:
	var input_movement := Vector2();
	if Input.is_action_pressed(&"move_down"):
		input_movement += Vector2(0.0, 1.0);
	if Input.is_action_pressed(&"move_up"):
		input_movement += Vector2(0.0, -1.0);
	if Input.is_action_pressed(&"move_left"):
		input_movement += Vector2(-1.0, 0.0);
	if Input.is_action_pressed(&"move_right"):
		input_movement += Vector2(1.0, 0.0);
	
	if assume_direct_control:
		input_movement = Vector2();
		return;
	
	velocity = input_movement * speed;
	move_and_slide()
	
	_stored_movement = input_movement;


func start_plushing() -> void:
	if plush_tween != null:
		return;
	
	plush_tween = create_tween();
	plush_tween.tween_property(sprite, ^"scale", Vector2(0.9, 1.1), 0.1)
	plush_tween.tween_property(sprite, ^"scale", Vector2(1.1, 0.9), 0.1)
	plush_tween.tween_property(sprite, ^"scale", Vector2(1.0, 1.0), 0.1)
	plush_tween.tween_callback(func() -> void: plush_tween.kill(); plush_tween = null)


func _add_area(area: Area2D) -> void:
	if area.owner != null:
		if area.owner is Item or area.owner is Station:
			overlapping[area] = area.owner;


func _remove_area(area: Area2D) -> void:
	if area.owner != null:
		if area.owner is Item or area.owner is Station:
			overlapping.erase(area);


func get_closest() -> Node2D:
	if overlapping.size() == 0:
		return null;
	
	if overlapping.size() == 1:
		return overlapping.values()[0];
	
	var minimal : float = -1.0;
	var closest_area : Area2D = null;
	
	for area in overlapping:
		var node := overlapping[area];
		var distance := node.position.distance_to(self.position);
		if minimal == -1.0:
			minimal = distance;
			closest_area = area;
		elif distance <= minimal:
			minimal = distance;
			closest_area = area;
	
	return overlapping[closest_area];


func activate_something(thing: Node2D) -> void:
	if thing == null:
		return;
	
	if thing is Item:
		var thing_item := thing as Item;
		thing_item.activate()
	
	if thing is Station:
		var thing_station := thing as Station;
		thing_station.activate()


func deactivate_something(thing: Node2D) -> void:
	if thing == null:
		return;
	
	if thing is Item:
		var thing_item := thing as Item;
		thing_item.deactivate()
	
	if thing is Station:
		var thing_station := thing as Station;
		thing_station.deactivate()


func try_use_something() -> void:
	if _previously_activated == null:
		pass;
	
	if _previously_activated is Item:
		var item := _previously_activated as Item;
		if inventory == null:
			pick_item(item);
			_remove_area(item.hitbox);
		
		if inventory != null and inventory != item:
			drop_item(item);
			_remove_area(item.hitbox);
	
	if _previously_activated is Station:
		var station := _previously_activated as Station;
		
		var station_occupied := station.has_item();
		var inventory_occupied := inventory != null;
		
		match [station_occupied, inventory_occupied]:
			[true, true]:
				var station_item := station._item;
				var is_cultist := station_item.item_name == "cultist";
				var has_knife := inventory.item_name == "knife";
				
				if is_cultist and has_knife and station_item is NonPlayerCharacter:
					var free_cultist : NonPlayerCharacter = station.dispense_item();
					free_cultist.sacrifice();
			
			[false, true]:
				station.receive_item(inventory);
				BGMPlayer.play_one_off(inventory.insert_sound);
				inventory = null;
			
			[true, false]:
				var item := station.dispense_item();
				pick_item(item);
			
			[false, false]:
				pass;


func pick_item(item: Item) -> void:
	if inventory != null:
		return;
	
	if item == null:
		return;
	
	inventory = item;
	if item.visible_when_carred:
		item.show();
	else:
		item.hide();
	
	BGMPlayer.play_one_off(item.take_sound);
	item.reparent(self);
	item.position = item.carried_offset + carried_item_position.position;
	item.deactivate();
	item.mark_taken();


func drop_item(swap_with: Item = null) -> void:
	if inventory == null:
		return;
	
	BGMPlayer.play_one_off(inventory.drop_sound);
	
	if swap_with == null:
		inventory.position = Vector2();
		_drop_item();
	else:
		var local_pos := to_local(swap_with.global_position);
		inventory.position = local_pos;
		_drop_item();
		pick_item(swap_with);


func _drop_item() -> void:
	if inventory == null:
		return;
	
	inventory.reparent(get_parent());
	inventory.unmark_taken();
	inventory.show();
	inventory = null;


func try_drop_something() -> void:
	if inventory != null:
		drop_item();


var _smoke_tween : Tween;
func explode() -> void:
	if smoke_cloud == null:
		return;
	
	if _smoke_tween:
		_smoke_tween.kill();
	
	_smoke_tween = create_tween();
	var random_rotation := randf() * 2.0 * PI;
	var explosion_time := 0.05;
	var dissipation_time := 0.2;
	
	smoke_cloud.self_modulate = Color(1, 1, 1, 0.5)
	smoke_cloud.scale = Vector2(0.5, 0.5)
	smoke_cloud.rotation = random_rotation - 0.1;
	smoke_cloud.show();
	
	# explosion
	_smoke_tween.tween_property(
		smoke_cloud, ^"self_modulate", Color(1, 1, 1, 1.0), explosion_time)
	_smoke_tween.parallel().tween_property(
		smoke_cloud, ^"scale", Vector2(1, 1), explosion_time)
	_smoke_tween.parallel().tween_property(
		smoke_cloud, ^"rotation", random_rotation, explosion_time)
	
	# dissipation
	_smoke_tween.tween_property(
		smoke_cloud, ^"self_modulate", Color(1, 1, 1, 0.2), dissipation_time)
	_smoke_tween.parallel().tween_property(
		smoke_cloud, ^"scale", Vector2(1.2, 1.2), dissipation_time)
	_smoke_tween.parallel().tween_property(
		smoke_cloud, ^"rotation", random_rotation + 0.2, dissipation_time)
	
	# hide
	_smoke_tween.tween_callback(smoke_cloud.hide);

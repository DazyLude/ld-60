extends CharacterBody2D
class_name Character


@export var inventory : Item;
@export var interaction_hitbox : Area2D;
@export var sprite : Sprite2D;
@export var carried_item_position : Marker2D;

@export var speed : float = 400;



var _stored_movement := Vector2()
var plush_tween : Tween;


var overlapping : Dictionary[Area2D, Node2D] = {};
var _previously_activated : Node2D;


func _ready() -> void:
	interaction_hitbox.area_entered.connect(_add_area)
	interaction_hitbox.area_exited.connect(_remove_area)
	HUD.register_player(self);


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"action"):
		try_use_something();
	
	if event.is_action_released(&"cancel"):
		try_drop_something();


func _process(_delta: float) -> void:
	if _stored_movement != Vector2() and plush_tween == null:
		start_plushing();
		_stored_movement = Vector2();
	
	var closest := get_closest();
	if closest != _previously_activated:
		deactivate_something(_previously_activated);
		activate_something(closest);
		_previously_activated = closest;


func _physics_process(delta: float) -> void:
	var input_movement := Vector2();
	if Input.is_action_pressed(&"move_down"):
		input_movement += Vector2(0.0, 1.0);
	if Input.is_action_pressed(&"move_up"):
		input_movement += Vector2(0.0, -1.0);
	if Input.is_action_pressed(&"move_left"):
		input_movement += Vector2(-1.0, 0.0);
	if Input.is_action_pressed(&"move_right"):
		input_movement += Vector2(1.0, 0.0);
	
	move_and_collide(input_movement * speed * delta)
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
		
		if inventory != null:
			drop_item(item);
			_remove_area(item.hitbox);
	
	if _previously_activated is Station:
		var station := _previously_activated as Station;
		
		var station_occupied := station.has_item();
		var inventory_occupied := inventory != null;
		
		match [station_occupied, inventory_occupied]:
			#[true, true]: 
				#var swap := station.dispense_item();
				#station.receive_item(inventory);
				#pick_item(swap);
			
			[false, true]:
				station.receive_item(inventory);
				inventory = null;
			
			[true, false]:
				var item := station.dispense_item();
				pick_item(item);
			
			[false, false]:
				pass;


func pick_item(item: Item) -> void:
	if inventory != null:
		return;
	
	inventory = item;
	if item.visible_when_carred:
		item.show();
	else:
		item.hide();
	
	item.reparent(self);
	item.position = item.carried_offset + carried_item_position.position;
	item.deactivate();
	item.mark_taken();


func drop_item(swap_with: Item = null) -> void:
	if inventory == null:
		return;
	
	if swap_with == null:
		inventory.position = Vector2();
		_drop_item();
	else:
		var local_pos := to_local(swap_with.global_position);
		inventory.position = local_pos;
		_drop_item();
		pick_item(swap_with);


func _drop_item() -> void:
	inventory.reparent(get_parent());
	inventory.unmark_taken();
	inventory.show();
	inventory = null;


func try_drop_something() -> void:
	if inventory != null:
		drop_item();

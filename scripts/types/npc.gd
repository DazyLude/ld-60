extends Item
class_name NonPlayerCharacter


signal sacrificed;


@export var route : Array[Waypoint] = [];
@export var reverse_loop : bool = true;

@export var respawn_point : Marker2D;

var plush_tween : Tween;
var movement_tween : Tween;

var tied : bool;
@export var tied_texture : Texture2D;
@export var highlighted_tied_texture : Texture2D;
@export var tied_sprite_offset : Marker2D;
@export var free_sprite_offset : Marker2D;
@export var tied_hitbox : Area2D;

var moving : bool = false;

var _smoke_tween : Tween;
@export var smoke_cloud : Sprite2D;
var _smoke_tween_2 : Tween;
@export var smoke_cloud_2 : Sprite2D;


func _ready() -> void:
	super();
	tied_hitbox.owner = self;
	
	if not route.is_empty():
		start_movement();
	
	update();


var cached_movement := Vector2();
func _process(_delta: float) -> void:
	if moving and not plush_tween:
		start_plushing();
	
	var current_pos := position;
	var xdiff := current_pos.x - cached_movement.x;
	if xdiff > 0.0:
		turn_right();
	elif xdiff < 0.0:
		turn_left();
	
	cached_movement = current_pos;


func mark_taken() -> void:
	stop_movement();
	tied = true;
	super();


func unmark_taken() -> void:
	super();
	update();


func activate() -> void:
	super();
	update();


func deactivate() -> void:
	super();
	update();


func turn_left() -> void:
	sprite.flip_h = false;


func turn_right() -> void:
	sprite.flip_h = true;


func start_movement() -> void:
	moving = true;
	if movement_tween:
		movement_tween.kill();
	
	movement_tween = create_tween();
	movement_tween.set_loops();
	
	var vd := respawn_point.position;
	
	for idx in route.size():
		var wp := route[idx];
		movement_tween.tween_property(self, ^"position", vd + wp.marker, wp.time);
	
	if reverse_loop:
		for neg_idx in route.size() - 1:
			var idx := route.size() - neg_idx - 2;
			var wp := route[idx];
			movement_tween.tween_property(self, ^"position", vd + wp.marker, wp.time);


func stop_movement() -> void:
	moving = false;
	if movement_tween:
		movement_tween.kill();


func respawn() -> void:
	tied = false;


func update() -> void:
	match [tied, active]:
		[false, false]:
			sprite.texture = item_texture;
			sprite.position = free_sprite_offset.position;
			hitbox.monitorable = not taken;
			tied_hitbox.monitorable = false;
		
		[false, true]:
			sprite.texture = highlighted_texture;
			sprite.position = free_sprite_offset.position;
			hitbox.monitorable = not taken;
			tied_hitbox.monitorable = false;
		
		[true, false]:
			sprite.texture = tied_texture;
			sprite.position = tied_sprite_offset.position;
			hitbox.monitorable = false;
			tied_hitbox.monitorable = not taken;
		
		[true, true]:
			sprite.texture = highlighted_tied_texture;
			sprite.position = tied_sprite_offset.position;
			hitbox.monitorable = false;
			tied_hitbox.monitorable = not taken;


func start_plushing() -> void:
	if plush_tween != null:
		return;
	
	if not tied:
		plush_tween = create_tween();
		plush_tween.tween_property(sprite, ^"scale", Vector2(0.9, 1.1), 0.3)
		plush_tween.tween_property(sprite, ^"scale", Vector2(1.1, 0.9), 0.3)
		plush_tween.tween_property(sprite, ^"scale", Vector2(1.0, 1.0), 0.3)
		plush_tween.tween_callback(func() -> void: plush_tween.kill(); plush_tween = null)


func sacrifice() -> void:
	sacrificed.emit();
	
	BGMPlayer.play_one_off(BGMPlayer.EffectID.BodyStab);
	
	var temp_position := global_position;
	reparent(respawn_point.get_parent());
	position = respawn_point.position;
	smoke_cloud_2.global_position = temp_position;
	
	explode();
	
	tied = false;
	unmark_taken();
	if not route.is_empty():
		start_movement();


func explode() -> void:
	if _smoke_tween:
		_smoke_tween.kill();
	
	_smoke_tween = create_tween();
	
	if _smoke_tween_2:
		_smoke_tween_2.kill();
	
	_smoke_tween_2 = create_tween();
	animate(_smoke_tween, smoke_cloud);
	animate(_smoke_tween_2, smoke_cloud_2);


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

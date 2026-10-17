extends Item
class_name NonPlayerCharacter


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


func _ready() -> void:
	super();
	tied_hitbox.owner = self;
	
	if not route.is_empty():
		start_movement();
	
	update();


func _process(_delta: float) -> void:
	if moving and not plush_tween:
		start_plushing();


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


func start_movement() -> void:
	pass;


func stop_movement() -> void:
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
		plush_tween.tween_property(sprite, ^"scale", Vector2(0.9, 1.1), 0.1)
		plush_tween.tween_property(sprite, ^"scale", Vector2(1.1, 0.9), 0.1)
		plush_tween.tween_property(sprite, ^"scale", Vector2(1.0, 1.0), 0.1)
		plush_tween.tween_callback(func() -> void: plush_tween.kill(); plush_tween = null)


class Waypoint extends Resource:
	@export var marker : Vector2;
	@export var time : float;

extends Node2D
class_name SacrificialAltar


signal sacrifice_made;
signal takodachi_arrived;


const appearance_time : float = 5.0;


@export var gem_holders : Array[Station] = [];
@export var cultist_holder : Station;
@export var takodachi_sprite : Sprite2D;
@export var talking_position : Marker2D;


var _bound_cultist : NonPlayerCharacter;
var takodachi_tween : Tween;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cultist_holder.item_received.connect(bind_cultist)


func bind_cultist(item: Item) -> void:
	if item is NonPlayerCharacter and item.item_name == "cultist":
		_bound_cultist = item;
		_bound_cultist.sacrificed.connect(check_all.bind(_bound_cultist));


func check_all(cultist : Item) -> void:
	if takodachi_tween:
		return;
	
	if cultist != _bound_cultist:
		cultist.sacrificed.disconnect(check_all);
		return;
	
	var correct := true;
	
	for holder in gem_holders:
		if holder is GemHolder:
			var gholder := holder as GemHolder;
			if not gholder.is_correct():
				correct = false;
				break;
	
	cultist.sacrificed.disconnect(check_all);
	if correct:
		cultist_holder.hitbox.monitorable = false;
		cultist_holder.deactivate();
		sacrifice_made.emit();
		spawn_takodachi();


func spawn_takodachi() -> void:
	takodachi_tween = create_tween();
	
	const sprite_height := 405.0;
	
	var takodachi_texture := takodachi_sprite.texture as AtlasTexture;
	var starting_y := takodachi_sprite.position.y;
	
	takodachi_sprite.show();
	takodachi_sprite.position.y = starting_y + sprite_height - 1.0;
	takodachi_texture.region.size.y = 1.0;
	
	var player := HUD.active_player;
	player.assume_direct_control = true;
	player.force_plushing = true;
	
	takodachi_tween.tween_property(takodachi_sprite, ^"position:y", starting_y, appearance_time);
	takodachi_tween.parallel().tween_property(
		takodachi_texture, ^"region:size:y", sprite_height, appearance_time);
	takodachi_tween.parallel().tween_property(
		player, ^"global_position", talking_position.global_position, appearance_time)
	takodachi_tween.tween_callback(
		func() -> void: player.force_plushing = false);

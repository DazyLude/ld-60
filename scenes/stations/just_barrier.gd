extends Node2D
class_name JustBarrier


@export var gem_holders : Array[Station] = [];
@export var barrier_hitbox : StaticBody2D;
@export var barrier_display : Node2D;


func _ready() -> void:
	for holder in gem_holders:
		holder.item_received.connect(check_solution.bind(holder))


func check_solution(_item: Item, holder: Station) -> void:
	if holder is GemHolder:
		var gholder := holder as GemHolder;
		if gholder.is_correct():
			check_all();


func check_all() -> void:
	var correct := true;
	
	for holder in gem_holders:
		if holder is GemHolder:
			var gholder := holder as GemHolder;
			if not gholder.is_correct():
				correct = false;
				break;
	
	if correct:
		barrier_hitbox.collision_layer = 0;
		barrier_display.hide();
		BGMPlayer.play_one_off(BGMPlayer.EffectID.DissapearanceBarrierSuzumia);
	else:
		barrier_hitbox.collision_layer = 1;

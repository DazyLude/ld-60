extends Node2D


var gem_l : ColoredGem = null
var gem_r : ColoredGem = null

@export var left_holder : GemHolder;
@export var right_holder : GemHolder;
@export var smoke_cloud : Sprite2D;
var _smoke_tween : Tween;


var reactions_table : Dictionary[GemPair, GemPair] = {
	# 1 - ColoredGem.Type.RUBY
	# 2 - ColoredGem.Type.EMERALD
	# 3 - ColoredGem.Type.SAPPHIRE
	# 4 - ColoredGem.Type.AMETHYST
	# 5 - ColoredGem.Type.CITRINE
	# 6 - ColoredGem.Type.DIAMOND
	# 7 - ColoredGem.Type.ONYX
	
	# base transposing reactions
	GemPair.from_arr([ColoredGem.Type.RUBY, ColoredGem.Type.SAPPHIRE]): # 1 + 3
		GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.CITRINE]), # 5 + 5
	GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.CITRINE]): # 5 + 5
		GemPair.from_arr([ColoredGem.Type.EMERALD, ColoredGem.Type.AMETHYST]), # 2 + 4
	GemPair.from_arr([ColoredGem.Type.EMERALD, ColoredGem.Type.AMETHYST]): # 2 + 4
		GemPair.from_arr([ColoredGem.Type.RUBY, ColoredGem.Type.SAPPHIRE]), # 1 + 3
	# 3
	
	# base circling reactions
	GemPair.from_arr([ColoredGem.Type.RUBY, ColoredGem.Type.EMERALD]): # 1 + 2
		GemPair.from_arr([ColoredGem.Type.SAPPHIRE, ColoredGem.Type.AMETHYST]), # 3 + 4
	GemPair.from_arr([ColoredGem.Type.EMERALD, ColoredGem.Type.SAPPHIRE]): # 2 + 3
		GemPair.from_arr([ColoredGem.Type.AMETHYST, ColoredGem.Type.RUBY]), # 4 + 1
	GemPair.from_arr([ColoredGem.Type.SAPPHIRE, ColoredGem.Type.AMETHYST]): # 3 + 4
		GemPair.from_arr([ColoredGem.Type.RUBY, ColoredGem.Type.EMERALD]), # 1 + 2
	GemPair.from_arr([ColoredGem.Type.AMETHYST, ColoredGem.Type.RUBY]): # 4 + 1
		GemPair.from_arr([ColoredGem.Type.EMERALD, ColoredGem.Type.SAPPHIRE]), # 2 + 3
	# 7
	
	# citrine-base reactions
	GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.RUBY]): # 1 + 5
		GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.SAPPHIRE]), # 3 + 5
	GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.SAPPHIRE]): # 3 + 5
		GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.RUBY]), # 1 + 5
	GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.EMERALD]): # 2 + 5
		GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.AMETHYST]), # 4 + 5
	GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.AMETHYST]): # 2 + 5
		GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.EMERALD]), # 4 + 5
	# 11
	
	# diamond-base reactions
	GemPair.from_arr([ColoredGem.Type.DIAMOND, ColoredGem.Type.RUBY]): # 1 + 6
		GemPair.from_arr([ColoredGem.Type.DIAMOND, ColoredGem.Type.AMETHYST]), # 4 + 6
	GemPair.from_arr([ColoredGem.Type.DIAMOND, ColoredGem.Type.AMETHYST]): # 4 + 6
		GemPair.from_arr([ColoredGem.Type.DIAMOND, ColoredGem.Type.SAPPHIRE]), # 3 + 6
	GemPair.from_arr([ColoredGem.Type.DIAMOND, ColoredGem.Type.SAPPHIRE]): # 3 + 6
		GemPair.from_arr([ColoredGem.Type.DIAMOND, ColoredGem.Type.EMERALD]), # 2 + 6
	GemPair.from_arr([ColoredGem.Type.DIAMOND, ColoredGem.Type.EMERALD]): # 2 + 6
		GemPair.from_arr([ColoredGem.Type.DIAMOND, ColoredGem.Type.RUBY]), # 1 + 6
	# 15
	
	# onyx-base reactions
	GemPair.from_arr([ColoredGem.Type.ONYX, ColoredGem.Type.RUBY]): # 1 + 7
		GemPair.from_arr([ColoredGem.Type.ONYX, ColoredGem.Type.EMERALD]), # 2 + 7
	GemPair.from_arr([ColoredGem.Type.ONYX, ColoredGem.Type.EMERALD]): # 2 + 7
		GemPair.from_arr([ColoredGem.Type.ONYX, ColoredGem.Type.SAPPHIRE]), # 3 + 7
	GemPair.from_arr([ColoredGem.Type.ONYX, ColoredGem.Type.SAPPHIRE]): # 3 + 7
		GemPair.from_arr([ColoredGem.Type.ONYX, ColoredGem.Type.AMETHYST]), # 4 + 7
	GemPair.from_arr([ColoredGem.Type.ONYX, ColoredGem.Type.AMETHYST]): # 4 + 7
		GemPair.from_arr([ColoredGem.Type.ONYX, ColoredGem.Type.RUBY]), # 1 + 7
	# 19
	
	# onyx-diamond-citrine
	GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.ONYX]): # 5 + 7
		GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.DIAMOND]), # 5 + 6
	GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.DIAMOND]): # 5 + 6
		GemPair.from_arr([ColoredGem.Type.CITRINE, ColoredGem.Type.ONYX]), # 5 + 7
	# 21
}


func _ready() -> void:
	left_holder.item_received.connect(left_received);
	right_holder.item_received.connect(right_received);
	left_holder.item_removed.connect(left_lost);
	right_holder.item_removed.connect(right_lost);


func left_received(gem: ColoredGem) -> void:
	gem_l = gem;
	check_reactions();


func left_lost() -> void:
	gem_l = null;


func right_received(gem: ColoredGem) -> void:
	gem_r = gem;
	check_reactions();


func right_lost() -> void:
	gem_r = null;


func check_reactions() -> void:
	if gem_l == null or gem_r == null:
		return;
	
	var gem_pair := GemPair.from_arr([gem_l.type, gem_r.type]);
	var recipe : GemPair = null;
	
	for key in reactions_table:
		if key.cis_eq(gem_pair):
			recipe = key;
			break;
		
		if key.tr_eq(gem_pair):
			recipe = key;
			
			recipe.swap();
			reactions_table[recipe].swap();
			
			break;
	
	if recipe == null:
		change_gem_types(gem_r.type, gem_l.type);
	else:
		var result := reactions_table[recipe];
		change_gem_types(result.st, result.nd);


func change_gem_types(type_l: ColoredGem.Type, type_r: ColoredGem.Type) -> void:
	if gem_l == null or gem_r == null:
		return;
	
	gem_l.type = type_l;
	gem_l.update();
	left_holder.item_slot.display_item(gem_l);
	
	gem_r.type = type_r;
	gem_r.update();
	right_holder.item_slot.display_item(gem_r);
	
	do_animation();


func do_animation() -> void:
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


class GemPair extends Resource:
	var st : ColoredGem.Type;
	var nd : ColoredGem.Type;
	
	static func from_arr(arr: Array[ColoredGem.Type]) -> GemPair:
		var pair := GemPair.new();
		if arr.size() < 2:
			return pair;
		
		pair.st = arr[0];
		pair.nd = arr[1];
		
		return pair;
	
	
	func cis_eq(other: GemPair) -> bool:
		var eq := other.st == self.st and other.nd == self.nd;
		return eq;
	
	
	func tr_eq(other: GemPair) -> bool:
		var eq := other.st == self.nd and other.nd == self.st;
		return eq;
	
	
	func swap() -> void:
		var t := st;
		st = nd;
		nd = t;

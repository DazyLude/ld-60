extends Level


@export var sacrificial : SacrificialAltar


var node_tweens : Dictionary[Node2D, Tween] = {};
@export var movement_triggers : Dictionary[GemHolder, MovementTriggerData] = {};
@export var movement_nodes : Dictionary[GemHolder, Node2D];
var _starting_positions : Dictionary[Node2D, Vector2];

@onready var default_teleports : Array[Area2D] = [
	$TeleportationCarpetSpawn/Teleport,
	$TeleportationCarpet00/Teleport, $TeleportationCarpet02/Teleport,
	$TeleportationCarpet20/Teleport, $TeleportationCarpet21/Teleport, $TeleportationCarpet22/Teleport,
	$TeleportationCarpet30/Teleport, $TeleportationCarpet31/Teleport, $TeleportationCarpet32/Teleport,
	$TeleportationCarpet40/Teleport, $TeleportationCarpet41/Teleport, $TeleportationCarpet42/Teleport,
	$TeleportationCarpet50/Teleport, $TeleportationCarpet51/Teleport,
	$TeleportationCarpet60/Teleport, $TeleportationCarpet61/Teleport, $TeleportationCarpet62/Teleport
];

@onready var variable_teleport : Area2D = $TeleportationCarpetVariable/Teleport;

@export var player : Character;
@export var smoke : Sprite2D;


var gem_vectors : Dictionary[ColoredGem.Type, Vector2i] = {
	ColoredGem.Type.CITRINE: Vector2i(0, 0), ColoredGem.Type.SAPPHIRE: Vector2i(1, 0),
	ColoredGem.Type.RUBY: Vector2i(0, 1), ColoredGem.Type.AMETHYST: Vector2i(1, 1),
	ColoredGem.Type.EMERALD: Vector2i(0, 2),
	ColoredGem.Type.ONYX: Vector2i(0, 3), ColoredGem.Type.DIAMOND: Vector2i(1, 3),
}

@export var targets : Array[GemHolder];

func _ready() -> void:
	super()
	HUD.quest_label.text = "quest_vampire";
	BGMPlayer.change_track(BGMPlayer.MusicID.Vampire);
	
	sacrificial.sacrifice_made.connect(_on_successful_sacrifice);
	
	for trigger in movement_triggers:
		var tdata := movement_triggers[trigger];
		var node := movement_nodes[trigger];
		add_trigger(trigger, node, tdata);
	
	for holder in movement_nodes:
		var node := movement_nodes[holder];
		_starting_positions[node] = node.position;
	
	for teleport in default_teleports:
		teleport.area_entered.connect(try_default_teleport)
	
	variable_teleport.area_entered.connect(try_targetable_teleport)


func _on_successful_sacrifice() -> void:
	shake()
	await shake_finished;
	await get_tree().create_timer(0.5).timeout;
	play_omake();


func add_trigger(trigger: GemHolder, node: Node2D, trigger_data: MovementTriggerData) -> void:
	trigger.item_received.connect(_check_trigger.bind(trigger, node, trigger_data));
	trigger.item_removed.connect(_reset_position.bind(node, trigger_data));


func _check_trigger(_item: Item, trigger: GemHolder, node: Node2D, trigger_data: MovementTriggerData) -> void:
	if trigger.is_correct():
		var starting_position := _starting_positions[node];
		move_node(
			node,
			starting_position + trigger_data.movement_delta,
			trigger_data.movement_time
		)


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


func try_default_teleport(area: Area2D) -> void:
	if teleporting:
		return;
	
	if area.owner is Character:
		var destination := get_teleport_target(Vector2i(1, 1))
		_teleport_to(destination)


func try_targetable_teleport(area: Area2D) -> void:
	if teleporting:
		return;
	
	if area.owner is Character:
		var destination := get_teleport_target(get_current_target())
		_teleport_to(destination)


var teleport_tween : Tween;
var teleporting : bool = false;
func _teleport_to(pos: Vector2) -> void:
	if teleport_tween:
		teleport_tween.kill();
	
	teleport_tween = create_tween();
	
	player.hide()
	player.assume_direct_control = true;
	teleporting = true;
	
	explode(player.global_position)
	get_tree().create_timer(0.27).timeout.connect(explode.bind(pos))
	BGMPlayer.play_one_off(BGMPlayer.EffectID.Bonk)
	
	teleport_tween.tween_property(player, ^"global_position", pos, 0.3);
	teleport_tween.tween_callback(player.show);
	teleport_tween.tween_callback(func() -> void: player.assume_direct_control = false);
	teleport_tween.tween_callback(func() -> void: teleporting = false);


var smoke_tween : Tween
func explode(at: Vector2) -> void:
	smoke.global_position = at
	
	if smoke_tween:
		smoke_tween.kill();
	
	smoke_tween = create_tween();
	
	var random_rotation := randf() * 2.0 * PI;
	var explosion_time := 0.05;
	var dissipation_time := 0.1;
	
	smoke.self_modulate = Color(1, 1, 1, 0.5)
	smoke.scale = Vector2(0.5, 0.5)
	smoke.rotation = random_rotation - 0.1;
	smoke.show();
	
	# explosion
	smoke_tween.tween_property(
		smoke, ^"self_modulate", Color(1, 1, 1, 1.0), explosion_time)
	smoke_tween.parallel().tween_property(
		smoke, ^"scale", Vector2(1, 1), explosion_time)
	smoke_tween.parallel().tween_property(
		smoke, ^"rotation", random_rotation, explosion_time)
	
	# dissipation
	smoke_tween.tween_property(
		smoke, ^"self_modulate", Color(1, 1, 1, 0.2), dissipation_time)
	smoke_tween.parallel().tween_property(
		smoke, ^"scale", Vector2(1.2, 1.2), dissipation_time)
	smoke_tween.parallel().tween_property(
		smoke, ^"rotation", random_rotation + 0.2, dissipation_time)
	
	# hide
	smoke_tween.tween_callback(smoke.hide);


func get_teleport_target(to: Vector2i = Vector2i(1, 1)) -> Vector2:
	to.x = clampi(to.x, 0, 2);
	to.y = clampi(to.y, 0, 6);
	var target : Vector2 = $TeleportTargets.get_node("%d%d" % [to.y, to.x]).position;
	return target;


func get_current_target() -> Vector2i:
	var target_cell := Vector2i();
	
	for target in targets:
		if target.has_item() and target._item is ColoredGem:
			var gem := target._item as ColoredGem;
			target_cell += gem_vectors[gem.type]
		else:
			return Vector2i(1, 1)
	
	return target_cell;

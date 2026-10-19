extends Level


@export var sacrificial : SacrificialAltar


var node_tweens : Dictionary[Node2D, Tween] = {};

@export var movement_triggers : Dictionary[GemHolder, MovementTriggerData] = {};
@export var movement_nodes : Dictionary[GemHolder, Node2D];
var _starting_positions : Dictionary[Node2D, Vector2];


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

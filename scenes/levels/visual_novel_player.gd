extends Control
class_name VNPlayer


signal finished;


enum Actor {
	None = -1,
	Millenial,
	Wizard,
	Vampire,
	Ghost,
	Narrator,
}

enum Emotes {
	None = -1,
	Normal,
	Talking,
	Shocked,
	Sad,
	TalkingUUU,
	Relaxed,
}

enum Reaction {
	None,
	Nudge,
	Shake,
	SlideIn,
}

enum Effect {
	None,
	FadeToBlack,
	FadeFromBlack,
}

enum TextEffect {
	
}


const TIME_PER_CHARACTER := 0.06;
var text_tweener : Tween;


@export var sprites : Dictionary[Actor, TextureRect] = {};
@export var character_emotes : Dictionary[Actor, EmoteTable] = {};
@export var box_textures : Dictionary[Actor, Texture2D] = {};


@export var label : RichTextLabel;
@export var narrator_label : Label;
@export var drapes : TextureRect;


var _dialogue : Node;
var current_root_node : Node;
var current_siblings : Array[Node] = [];
var current_idx : int = 0;


func _ready() -> void:
	HUD.hide();
	if _dialogue:
		play_next();


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _dialogue != null:
			_dialogue.queue_free();


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"action"):
		play_next();
		return;
	
	if event is InputEventMouseButton:
		var mbevent := event as InputEventMouseButton;
		if mbevent.pressed and mbevent.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			play_next();
			return;


func play_dialogue(dialogue: DialogueNode) -> void:
	if _dialogue:
		_dialogue.queue_free();
	
	add_child(dialogue);
	_dialogue = dialogue;
	current_root_node = dialogue;


func play_next() -> void:
	if current_siblings.is_empty(): # play the root node
		current_siblings = current_root_node.get_children();
		current_idx = -1;
		play_dialogue_node(current_root_node as DialogueNode);
		return;
	
	current_idx += 1;
	if current_idx >= current_siblings.size():
		#TODO advance deeper in the tree
		finished.emit();
		return;
	
	play_dialogue_node(current_siblings[current_idx] as DialogueNode);


func blackout() -> void:
	drapes.modulate = Color(1,1,1,1);


func unblackout() -> void:
	drapes.modulate = Color(1,1,1,0);


func play_dialogue_node(node: DialogueNode) -> void:
	clear_text();
	
	match node.actor:
		Actor.Narrator:
			play_narrator_text(node.character_line);
		_:
			play_actor_text(node.character_line);
	
	match node.effect:
		Effect.FadeFromBlack:
			unblackout();
	
	
	if node.autoplay:
		play_next();


func clear_text() -> void:
	narrator_label.text = "";
	label.text = "";


func play_narrator_text(text: String) -> void:
	if text == "":
		return;
	
	if text_tweener:
		text_tweener.kill();
	
	text_tweener = create_tween();
	
	narrator_label.visible_ratio = 0.0;
	narrator_label.text = text;
	text_tweener.tween_property(narrator_label, ^"visible_ratio", 1.0, text.length() * TIME_PER_CHARACTER);


func play_actor_text(text: String) -> void:
	if text == "":
		return;
	
	if text_tweener:
		text_tweener.kill();
	
	text_tweener = create_tween();
	
	label.visible_ratio = 0.0;
	label.text = text;
	text_tweener.tween_property(label, ^"visible_ratio", 1.0, text.length() * TIME_PER_CHARACTER);

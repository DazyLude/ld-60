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
	Grimoire,
	Takodachi,
	Zoomer,
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
	Shaking,
	Wave,
}


const TIME_PER_CHARACTER := 0.06;
var text_tweener : Tween;


@export var sprites : Dictionary[Actor, TextureRect] = {};
@export var character_emotes : Dictionary[Actor, EmoteTable] = {};
@export var box_textures : Dictionary[Actor, Texture2D] = {};
var actor_themes : Dictionary[Actor, Theme] = {
	Actor.Ghost: preload("res://assets/themes/ghost.tres"),
	Actor.Millenial: preload("res://assets/themes/millenial.tres"),
	Actor.Narrator: preload("res://assets/themes/narrator.tres"),
	Actor.Vampire: preload("res://assets/themes/vampire.tres"),
	Actor.Takodachi: preload("res://assets/themes/vampire.tres"),
	Actor.Wizard: preload("res://assets/themes/wizard.tres"),
	Actor.Grimoire: preload("res://assets/themes/wizard.tres"),
	Actor.Zoomer: preload("res://assets/themes/zoomer.tres"),
}

var actor_themes_cy : Dictionary[Actor, Theme] = {
	Actor.Ghost: preload("res://assets/themes/cyrillic/ghost.tres"),
	Actor.Millenial: preload("res://assets/themes/cyrillic/millenial.tres"),
	Actor.Vampire: preload("res://assets/themes/cyrillic/vampire.tres"),
	Actor.Takodachi: preload("res://assets/themes/cyrillic/vampire.tres"),
	Actor.Wizard: preload("res://assets/themes/cyrillic/wizard.tres"),
	Actor.Grimoire: preload("res://assets/themes/cyrillic/wizard.tres"),
}


@export var text_box : TextureRect;
@export var label : RichTextLabel;
@export var narrator_label : Label;
@export var drapes : TextureRect;


var _dialogue : Node;
var current_root_node : Node;
var current_siblings : Array[Node] = [];
var current_idx : int = 0;

var skippable : bool = true;


func _ready() -> void:
	drapes.modulate = Color(1,1,1,0);
	HUD.hide();
	if _dialogue:
		play_next();


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _dialogue != null:
			_dialogue.queue_free();


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"action"):
		if skippable:
			play_next();
		return;
	
	if event is InputEventMouseButton and not event.is_echo():
		var mbevent := event as InputEventMouseButton;
		if mbevent.pressed and mbevent.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if skippable:
				play_next();
			return;


func play_dialogue(dialogue: DialogueNode) -> void:
	if _dialogue:
		_dialogue.queue_free();
	
	add_child(dialogue);
	_dialogue = dialogue;
	current_root_node = dialogue;


func play_next() -> void:
	if text_tweener and text_tweener.is_running():
		return;
	
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
	
	if node.character_line != "":
		node.character_line = tr(node.character_line);
		
		match node.actor:
			Actor.Narrator:
				play_narrator_text(node.character_line);
			_:
				setup_actor_box(node.actor);
				play_actor_text(node.actor, node.character_line);
	
	match node.effect:
		Effect.FadeFromBlack:
			unblackout();
		Effect.FadeToBlack:
			blackout();
	
	if node.autoplay:
		skippable = false;
		if node.autoplay_time == -1.0 and text_tweener and text_tweener.is_running():
			await text_tweener.finished
		else:
			await get_tree().create_timer(node.autoplay_time).timeout;
		
		play_next();
	else:
		skippable = true;


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


func setup_actor_box(actor: Actor) -> void:
	text_box.texture = box_textures.get(actor, null);


func setup_actor_theme(actor: Actor) -> void:
	var current_locale := TranslationServer.get_locale();
	var ltheme : Theme = null;
	
	if current_locale == "ru":
		ltheme = actor_themes_cy.get(actor, null);
		if ltheme != null:
			label.theme = ltheme;
			return;
	
	ltheme = actor_themes.get(actor, actor_themes[Actor.Narrator]);
	label.theme = ltheme;


func play_actor_text(actor: Actor, text: String) -> void:
	if text == "":
		return;
	
	if text_tweener:
		text_tweener.kill();
	
	text_tweener = create_tween();
	
	setup_actor_theme(actor);
	
	label.visible_ratio = 0.0;
	label.text = text;
	text_tweener.tween_property(label, ^"visible_ratio", 1.0, text.length() * TIME_PER_CHARACTER);

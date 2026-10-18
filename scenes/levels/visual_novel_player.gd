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
	Laugh,
	TurnAround,
	SlideIn,
}


enum Effect {
	None,
	FadeToBlack,
	FadeFromBlack,
	InstantToBlack,
}

enum TextEffect {
	None,
	Shake,
	Wave,
}


const te_prefixes : Dictionary[TextEffect, String] = {
	TextEffect.Shake: "[shake rate=20.0 level=5 connected=1]",
	TextEffect.Wave: "[wave amp=50.0 freq=5.0 connected=1]",
}

const te_postfixes : Dictionary[TextEffect, String] = {
	TextEffect.Shake: "[/shake]",
	TextEffect.Wave: "[/wave]",
}




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

var character_tweens : Dictionary[Actor, Tween] = {};
var _default_positions : Dictionary[Actor, Vector2] = {};

const transition_time := 0.5;
var drapes_tween : Tween;
const TIME_PER_CHARACTER := 0.06;
var text_tweener : Tween;


func _ready() -> void:
	drapes.modulate = Color(1, 1, 1, 0);
	HUD.hide();
	for actor in sprites:
		_default_positions[actor] = sprites[actor].position;
	
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
	if drapes_tween:
		drapes_tween.kill();
	
	drapes_tween = create_tween();
	drapes.show();
	drapes_tween.tween_property(drapes, ^"modulate:a", 1.0, transition_time);


func instant_blackout() -> void:
	drapes.show();
	drapes.modulate.a = 1.0;


func unblackout() -> void:
	if drapes_tween:
		drapes_tween.kill();
	
	drapes_tween = create_tween();
	drapes.show();
	drapes_tween.tween_property(drapes, ^"modulate:a", 0.0, transition_time);


func play_dialogue_node(node: DialogueNode) -> void:
	clear_text();
	var line := node.character_line;
	
	if line != "":
		if node.reaction == Reaction.None:
			node.reaction = Reaction.Nudge;
		
		line = tr(line);
		match node.text_effect:
			TextEffect.Wave:
				line = te_prefixes[TextEffect.Wave] + line + te_postfixes[TextEffect.Wave];
			TextEffect.Shake:
				line = te_prefixes[TextEffect.Shake] + line + te_postfixes[TextEffect.Shake];
		
		match node.actor:
			Actor.Narrator:
				play_narrator_text(line);
			_:
				setup_actor_box(node.actor);
				play_actor_text(node.actor, line);
	
	setup_actor_emote(node.actor, node.emote);
	
	match node.reaction:
		Reaction.Nudge:
			nudge(node.actor)
		Reaction.Shake:
			shake(node.actor)
		Reaction.Laugh:
			laugh(node.actor)
		Reaction.TurnAround:
			turn_around(node.actor)
		Reaction.SlideIn:
			pass;
	
	match node.effect:
		Effect.FadeFromBlack:
			unblackout();
		Effect.FadeToBlack:
			blackout();
		Effect.InstantToBlack:
			instant_blackout();
	
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


func setup_actor_emote(actor: Actor, emote: Emotes) -> void:
	if emote == Emotes.None:
		return;
	
	var sprite : TextureRect = sprites.get(actor);
	if sprite == null:
		return;
	
	var emote_table : EmoteTable = character_emotes.get(actor);
	if emote_table == null:
		return;
	
	var emote_texture := emote_table.get_emote(emote);
	if emote_table == null:
		return;
	
	sprite.texture = emote_texture;


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
	var cc := label.get_total_character_count();
	text_tweener.tween_property(label, ^"visible_ratio", 1.0, cc * TIME_PER_CHARACTER);


func get_new_actor_tween(actor: Actor) -> Tween:
	var character_tween : Tween = character_tweens.get(actor);
	if character_tween:
		character_tween.kill();
		reset_actor(actor);
	
	character_tween = create_tween();
	character_tweens[actor] = character_tween;
	return character_tween;


func reset_actor(actor: Actor) -> void:
	var sprite : TextureRect = sprites.get(actor);
	if sprite == null:
		return;
	
	sprite.position = _default_positions[actor];
	sprite.scale = Vector2(1, 1);
	sprite.rotation = 0.0;


func laugh(actor: Actor) -> void:
	var sprite : TextureRect = sprites.get(actor);
	if sprite == null:
		return;
	
	var tween := get_new_actor_tween(actor);
	var starting_pos := sprite.position;
	
	const delta : float = 0.1;
	var laugh_offset_up := Vector2(0.0, -10.0)
	var laugh_offset_down := Vector2(0.0, 10.0)
	
	if actor == Actor.Vampire:
		laugh_offset_up *= Vector2(1.0, -1.0);
		laugh_offset_down *= Vector2(1.0, -1.0);
	
	tween.tween_property(sprite, ^"position", starting_pos + laugh_offset_up, delta);
	tween.tween_property(sprite, ^"position", starting_pos + laugh_offset_down, delta * 2);
	tween.tween_property(sprite, ^"position", starting_pos + laugh_offset_up, delta * 2);
	tween.tween_property(sprite, ^"position", starting_pos, delta);


func nudge(actor: Actor) -> void:
	var sprite : TextureRect = sprites.get(actor);
	if sprite == null:
		return;
	
	var tween := get_new_actor_tween(actor);
	var starting_pos := sprite.position;
	const delta : float = 0.05;
	var nudge_offset_up := Vector2(0.0, -10.0);
	
	if actor == Actor.Vampire:
		nudge_offset_up *= Vector2(1.0, -1.0);
	
	tween.tween_property(sprite, ^"position", starting_pos + nudge_offset_up, delta);
	tween.tween_property(sprite, ^"position", starting_pos, delta);


func shake(actor: Actor) -> void:
	var sprite : TextureRect = sprites.get(actor);
	if sprite == null:
		return;
	
	var tween := get_new_actor_tween(actor);
	var starting_pos := sprite.position;
	const delta : float = 0.1;
	
	var point_1 := Vector2(10.0, -20.0);
	var point_2 := Vector2(-20.0, 10.0);
	var point_3 := Vector2(10.0, 20.0);
	var point_4 := Vector2(-20.0, -10.0);
	
	tween.tween_property(sprite, ^"position", starting_pos + point_1, delta);
	tween.tween_property(sprite, ^"position", starting_pos + point_2, delta);
	tween.tween_property(sprite, ^"position", starting_pos + point_3, delta);
	tween.tween_property(sprite, ^"position", starting_pos + point_4, delta);
	tween.tween_property(sprite, ^"position", starting_pos, delta);


func turn_around(actor: Actor) -> void:
	var sprite : TextureRect = sprites.get(actor);
	if sprite == null:
		return;
	
	sprite.flip_h = not sprite.flip_h;


func just_text_box() -> void:
	for child in get_children():
		if child == text_box:
			continue;
		
		child.hide();

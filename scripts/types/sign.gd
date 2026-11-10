extends Node2D
class_name Sign


@export var station_name : String;
@export var hitbox : Area2D;
@export var item_placement : Marker2D;
@export var starting_item : Item;


@export var text_label_root : Control;
@export var unread_marker : Node2D;


var closed_texture : Texture2D = preload("res://assets/visuals/items/closed_textbook.png");
var opened_texture : Texture2D = preload("res://assets/visuals/items/open_grimoire.png");


var _item : Item;


func _ready() -> void:
	if starting_item != null:
		_equip_deferred.call_deferred();
	
	deactivate();
	hitbox.owner = self;


func _equip_deferred() -> void:
	starting_item.mark_taken();
	starting_item.reparent(self);
	starting_item.position = item_placement.position;
	starting_item.show();
	_item = starting_item;


func activate() -> void:
	unread_marker.hide();
	text_label_root.visible = true;
	transition_modulate(Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0))
	starting_item.sprite.texture = opened_texture;
	BGMPlayer.play_one_off(BGMPlayer.EffectID.BookTake);


func deactivate() -> void:
	starting_item.sprite.texture = closed_texture;
	transition_modulate(Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0))
	BGMPlayer.play_one_off(BGMPlayer.EffectID.ObjectFall);



var transition_tween : Tween;
func transition_modulate(from: Color, to: Color) -> void:
	if transition_tween:
		transition_tween.kill()
	
	text_label_root.modulate = from;
	transition_tween = create_tween();
	transition_tween.tween_property(text_label_root, ^"modulate", to, 0.07);

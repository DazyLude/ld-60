extends Node2D
class_name Item


@export var item_name : String = "";

@export var item_texture : Texture2D;
@export var highlighted_texture : Texture2D;

@export var hitbox : Area2D;
@export var sprite : Sprite2D;
var active : bool;
var taken : bool;

@export var carried_offset : Vector2;
@export var visible_when_carred : bool = false;

@export var take_sound := BGMPlayer.EffectID.GemTake;
@export var drop_sound := BGMPlayer.EffectID.None;
@export var insert_sound := BGMPlayer.EffectID.None;


func _ready() -> void:
	sprite.texture = item_texture;
	hitbox.owner = self;


func activate() -> void:
	active = true;
	sprite.texture = highlighted_texture;


func deactivate() -> void:
	active = false;
	sprite.texture = item_texture;


func mark_taken() -> void:
	taken = true;
	hitbox.monitorable = false;


func unmark_taken() -> void:
	taken = false;
	hitbox.monitorable = true;

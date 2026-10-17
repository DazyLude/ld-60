extends Node2D
class_name Item


@export var item_name : String = "";

@export var item_texture : Texture2D;
@export var highlighted_texture : Texture2D;

@export var hitbox : Area2D;
@export var sprite : Sprite2D;


func _ready() -> void:
	hitbox.owner = self;


func activate() -> void:
	sprite.texture = highlighted_texture;


func deactivate() -> void:
	sprite.texture = item_texture;


func mark_taken() -> void:
	hitbox.monitorable = false;


func unmark_taken() -> void:
	hitbox.monitorable = true;

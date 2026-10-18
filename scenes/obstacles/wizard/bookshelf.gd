extends Node2D


@export var variants : Array[Texture2D] = [];
@export var sprite : Sprite2D
@export var flip : bool = false


func _ready() -> void:
	sprite.texture = variants.pick_random();
	sprite.flip_h = flip;

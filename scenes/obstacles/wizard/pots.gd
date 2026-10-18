extends Node2D


@export var flip : bool = false;
@export var random_flip : bool = false
@export var sprite : Sprite2D;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if random_flip:
		flip = randf() >= 0.5;
	
	sprite.flip_h = flip;

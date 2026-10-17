extends Item
class_name ColoredGem


enum Type {
	RUBY = 0,
	SAPPHIRE = 1,
	CITRINE = 2,
	AMETHYST = 3,
	EMERALD = 4,
	DIAMOND = 5,
	ONYX = 6,
}


@export var type : Type = Type.RUBY;
@export var textures_per_type : Dictionary[Type, Texture2D];
@export var h_textures_per_type : Dictionary[Type, Texture2D];


func _ready() -> void:
	item_texture = textures_per_type[type];
	highlighted_texture = h_textures_per_type[type];
	super();


func update() -> void:
	item_texture = textures_per_type[type];
	highlighted_texture = h_textures_per_type[type];
	
	if active:
		sprite.texture = highlighted_texture;
	else:
		sprite.texture = item_texture;

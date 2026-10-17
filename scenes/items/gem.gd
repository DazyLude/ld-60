extends Item
class_name ColoredGem


enum Type {
	RUBY,
	SAPPHIRE,
	CITRINE,
	AMETHYST,
	EMERALD,
	DIAMOND,
	ONYX,
}


@export var type : Type = Type.RUBY;
@export var textures_per_type : Dictionary[Type, Texture2D];
@export var h_textures_per_type : Dictionary[Type, Texture2D];


func _ready() -> void:
	item_texture = textures_per_type[type];
	highlighted_texture = h_textures_per_type[type];
	super();

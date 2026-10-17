extends Station


enum Type {
	ANY,
	RUBY,
	SAPPHIRE,
	CITRINE,
	AMETHYST,
	EMERALD,
	DIAMOND,
	ONYX,
}


@export var texture_per_type : Dictionary[Type, Texture2D] = {}
@export var type : Type;
@export var sprite : Sprite2D;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = texture_per_type[type];
	super()

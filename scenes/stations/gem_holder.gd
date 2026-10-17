extends Station
class_name GemHolder


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


var type_comparison : Dictionary[Type, ColoredGem.Type] = {
	Type.RUBY: ColoredGem.Type.RUBY,
	Type.SAPPHIRE: ColoredGem.Type.SAPPHIRE,
	Type.CITRINE: ColoredGem.Type.CITRINE,
	Type.AMETHYST: ColoredGem.Type.AMETHYST,
	Type.EMERALD: ColoredGem.Type.EMERALD,
	Type.DIAMOND: ColoredGem.Type.DIAMOND,
	Type.ONYX: ColoredGem.Type.ONYX,
}


@export var texture_per_type : Dictionary[Type, Texture2D] = {}
@export var type : Type;
@export var sprite : Sprite2D;


func _ready() -> void:
	sprite.texture = texture_per_type[type];
	super()


func is_correct() -> bool:
	if not has_item():
		return false;
	
	if not _item is ColoredGem:
		return false;
	
	if type == Type.ANY:
		return true;
	
	var gem := _item as ColoredGem;
	var required_type := type_comparison[type];
	
	return required_type == gem.type;

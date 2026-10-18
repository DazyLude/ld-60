extends Resource
class_name EmoteTable

@export
var _d : Dictionary[VNPlayer.Emotes, Texture2D] = {};


func get_emote(emo: VNPlayer.Emotes) -> Texture2D:
	return _d.get(emo, null);

extends Node
class_name DialogueNode


@export var autoplay : bool = false;
@export var autoplay_time : float = 0.0;

@export var actor := VNPlayer.Actor.None;
@export var emote := VNPlayer.Emotes.None;
@export var reaction := VNPlayer.Reaction.None;
@export var character_line : String;

@export var effect := VNPlayer.Effect.None;

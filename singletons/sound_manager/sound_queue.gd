@tool
class_name SoundQueue
extends Node

var _next = 0
var _audioStreamPlayers: Array[AudioStreamPlayer] = []

@export var count: int = 1


func _ready() -> void:
	if get_child_count() == 0:
		print("No AudioStreamPlayer child found.")
		return
	
	var child = get_child(0)
	if child.get_class() == "AudioStreamPlayer":
		_audioStreamPlayers.append(child)
		
		for i in count:
			var dup = child.duplicate()
			add_child(dup)
			_audioStreamPlayers.append(dup)
			


func _get_configuration_warning() -> String:
	var warning := ""
		
	if get_child_count() == 0:
		warning += "No children found. Expected one AudioStreamPlayer child."
	
	if get_child(0).get_class() != "AudioStreamPlayer":
		warning += "Expected first child to be an AudioStreamPlayer."
	
	return warning


func play_sound() -> void:
	if !_audioStreamPlayers[_next].playing:
		_audioStreamPlayers[_next].play()
		_next += 1
		_next %= _audioStreamPlayers.size()
		
		

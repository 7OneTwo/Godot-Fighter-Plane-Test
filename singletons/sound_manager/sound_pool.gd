@tool
class_name SoundPool
extends Node


var _sounds = Array()
var _last_index := -1


func _ready() -> void:
	for child in get_children():
		if child is SoundQueue:
			_sounds.append(child as SoundQueue)


func play_random_sound() -> void:
	var index: int
	while index == _last_index:
		index = randi_range(0, _sounds.size() - 1)
		
	_last_index = index
	_sounds[index].play_sound()

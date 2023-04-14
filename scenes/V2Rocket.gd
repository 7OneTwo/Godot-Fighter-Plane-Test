extends Node2D

@export var speed: float = -800.0

@onready var thrust := $V2Thrust

var movement_vector := Vector2(1, 0)
var rand = RandomNumberGenerator.new()


func _process(delta: float) -> void:
	rand.randomize()
	global_position += movement_vector.rotated(rotation) * speed * delta


func _physics_process(delta: float) -> void:
	var x = randf_range(0.5, 1)
	var y = randf_range(0.75, 1)
	thrust.scale = Vector2(x, y)


func _on_thrust_sound_finished() -> void:
	queue_free()

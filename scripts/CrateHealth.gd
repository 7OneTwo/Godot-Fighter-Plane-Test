extends Sprite2D


signal heal()


var x_speed: float = 75
var y_speed: float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= x_speed * delta
	position.y += y_speed * delta


func take_damage(amount: int, body: Area2D) -> void:
	if body.get_parent().is_in_group("Player Bullets") and !$FadeOut.is_playing():
		emit_signal("heal")
		$FadeOut.play("fade_out")
		$RewardSound.play()


func _on_fade_out_animation_finished(anim_name: StringName) -> void:
	queue_free()

extends Node2D

signal explode_enemy(explosion)

@export var health: int = 6
@export var speed: float = -800.0

@onready var thrust := $V2Thrust
@onready var richochet_sound := $RicoshetSoundPool
@onready var hurt_box := $HurtBox
@onready var hit_box := $HitBox

var explosion_scene = preload("res://scenes/Explosion.tscn")

var movement_vector := Vector2(1, 0)
var current_health: float
var rand = RandomNumberGenerator.new()


func _ready() -> void:
	current_health = health


func _process(delta: float) -> void:
	rand.randomize()
	global_position += movement_vector.rotated(rotation) * speed * delta


func _physics_process(delta: float) -> void:
	var x = randf_range(0.5, 1)
	var y = randf_range(0.75, 1)
	thrust.scale = Vector2(x, y)


func _on_thrust_sound_finished() -> void:
	queue_free()

func take_damage(amount: int, body: Area2D) -> void:
	if body.get_parent().is_in_group("Enemy Planes"):
		return
		
	current_health -= amount
	richochet_sound.play_random_sound()
		
	if current_health <=0:
		explode_v2()
		queue_free()

func explode_v2() -> void:
	var e = explosion_scene.instantiate()
	e.global_position = global_position
	e.scale = Vector2(2, 2)
	emit_signal("explode_enemy", e)

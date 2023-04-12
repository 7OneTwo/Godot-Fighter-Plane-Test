extends Node2D


@onready var bullets = $ParallaxBackground/Bullets
@onready var explosions = $ParallaxBackground/Explosions
@onready var explosion_sound = $ExplosionSoundQueue
@onready var enemy_planes = $ParallaxBackground/EnemyPlanes
@onready var game_over = $GameOver
@onready var start_timer = $StartTimer
@onready var enemy_timer = $EnemyTimer

var player_scene = preload("res://scenes/player.tscn")
var enemy_plane = preload("res://scenes/EnemyPlane.tscn")

var spawn_y_min = 40
var spawn_y_max = 900
var spawn_interval_min = 2
var spawn_interval_max = 6
var rand = RandomNumberGenerator.new()


func _ready() -> void:
	rand.randomize()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fire") and game_over.visible:
		get_tree().reload_current_scene()


func _on_player_shoot(bullet) -> void:
	bullets.add_child(bullet)


func _on_player_explode(explosion) -> void:
	explosions.add_child(explosion)
	$ExplosionSoundQueue/AudioStreamPlayer.pitch_scale = 0.35
	explosion_sound.play_sound()
	game_over.visible = true


func _on_enemy_explode(explosion) -> void:
	explosions.add_child(explosion)
	explosion.set_rotation_degrees(rand.randi_range(0, 359))
	var s = rand.randf_range(1.0, 1.5)
	explosion.scale = Vector2(s, s)
	$ExplosionSoundQueue/AudioStreamPlayer.pitch_scale = randf_range(0.65, 1.0)
	explosion_sound.play_sound()


func _on_start_timer_timeout() -> void:
	_on_enemy_timer_timeout()
	enemy_timer.start()
	enemy_timer.wait_time = rand.randi_range(spawn_interval_min, spawn_interval_max)


func _on_enemy_timer_timeout() -> void:
	var enemy = enemy_plane.instantiate()
	enemy.connect("explode_enemy", _on_enemy_explode)
	enemy.position = Vector2(get_viewport_rect().size.x - 1, randi_range(spawn_y_min, spawn_y_max))
	enemy_planes.add_child(enemy)

	enemy_timer.wait_time = rand.randi_range(spawn_interval_min, spawn_interval_max)


func _on_player_game_over() -> void:
	enemy_timer.stop()

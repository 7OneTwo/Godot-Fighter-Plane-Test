extends Node2D

@export_category("Enemy Waves")
@export var starting_wave: int = 1
@export var plane_spawn_interval: float = 3.0
@export var plane_spawn_interval_dec:  = 0.0
@export var plane_spawn_count_inc: int = 2
@export var plane_starting_count: int = 15

@onready var bullets = $ParallaxBackground/Bullets
@onready var explosions = $ParallaxBackground/Explosions
@onready var enemy_planes = $ParallaxBackground/EnemyPlanes
@onready var game_start = $ParallaxBackground/GameStart
@onready var game_over = $ParallaxBackground/GameOver
@onready var game_over_anim = $ParallaxBackground/GameOverAnimation
@onready var wave_timer = $WaveTimer
@onready var v2_spawn_timer = $V2SpawnTimer
@onready var plane_spawn_timer = $PlaneSpawnTimer
@onready var player = $ParallaxBackground/Path2D/PathFollow2D/Player
@onready var hud = $HUD

var enemy_plane = preload("res://scenes/EnemyPlane.tscn")
var v2_rocket = preload("res://scenes/V2Rocket.tscn")

var spawn_y_min = 40
var spawn_y_max = 900
var spawn_interval_min = 2
var spawn_interval_max = 6
var rand = RandomNumberGenerator.new()

var score_label
var accuracy_label


func _ready() -> void:
	rand.randomize()
	score_label = hud.get_node("%ScoreLabel")
	accuracy_label = hud.get_node("%AccuracyLabel")
	player.get_tree().paused = true


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fire") and game_start.visible:
		hud.visible = true
		game_start.visible = false
		player.get_tree().paused = false
		wave_timer.start()
		v2_spawn_timer.start()

	if Input.is_action_just_pressed("fire") and game_over.visible:
		hud.visible = false
		get_tree().reload_current_scene()


func _on_player_shoot(bullet) -> void:
	bullets.add_child(bullet)


func _on_player_explode(explosion) -> void:
	explosions.add_child(explosion)
	explosion.explode(0.35)
	game_over.visible = true
	game_over_anim.play("game_over")


func _on_enemy_explode(explosion) -> void:
	var score = int(score_label.text) + 1
	score_label.text = "%s" % score
	explosions.add_child(explosion)
	explosion.set_rotation_degrees(rand.randi_range(0, 359))
	
	var s = rand.randf_range(1.0, 1.5)
	explosion.scale = Vector2(s, s)
	explosion.explode(1.5 - s + 0.5)


func _on_v2_explode(explosion) -> void:
	var score = int(score_label.text) + 25
	score_label.text = "%s" % score
	explosion.scale = Vector2(3, 3)
	explosions.add_child(explosion)
	explosion.set_rotation_degrees(rand.randi_range(0, 359))
	
	explosion.explode(0.35, "V2")


func _on_wave_timer_timeout() -> void:
	_on_plane_spawn_timer_timeout()
	plane_spawn_timer.start()
	#plane_spawn_timer.wait_time = rand.randi_range(spawn_interval_min, spawn_interval_max)
	plane_spawn_timer.wait_time = plane_spawn_interval


func _on_plane_spawn_timer_timeout() -> void:
	var enemy = enemy_plane.instantiate()
	enemy.connect("explode_enemy", _on_enemy_explode)
	enemy.position = Vector2(get_viewport_rect().size.x - 1, randi_range(spawn_y_min, spawn_y_max))
	enemy_planes.add_child(enemy)

	plane_spawn_timer.wait_time = rand.randi_range(spawn_interval_min, spawn_interval_max)


func _on_player_game_over() -> void:
	plane_spawn_timer.stop()
	v2_spawn_timer.stop()
	


func _on_v_2_spawn_timer_timeout() -> void:
	var v2 = v2_rocket.instantiate()
	v2.connect("explode_enemy", _on_v2_explode)
	v2.position = Vector2(get_viewport_rect().size.x - 1, player.global_position.y - 46)
	enemy_planes.add_child(v2)

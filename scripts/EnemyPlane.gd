extends Sprite2D

signal shoot(bullet)
signal explode_enemy(explosion)

@export var health: int = 3
@export var climb_angle_limit: float = -0.1
@export var dive_angle_limit: float = 0.1
@export var speed_min: float = 12
@export var speed_max: float = 16
@export_category("Gun")
@export var bullet_limit: int = 3
@export var fire_delay: float = 0.2


@onready var engine_sound: AudioStreamPlayer = $EngineSound
@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound
@onready var richochet_sound := $RicoshetSoundPool
@onready var hurt_box := $HurtBox
@onready var hit_box := $HitBox
@onready var engine_animation: AnimationPlayer = $EngineAnimation
@onready var engine_smoke = $EngineSmokeParticles
@onready var explosion = $Explosion
@onready var fire_start_timer = $FireStartTimer
@onready var fire_delay_timer = $FireDelayTimer
@onready var muzzle = $Muzzle

var bullet_scene = preload("res://scenes/EnemyBullet.tscn")
var explosion_scene = preload("res://scenes/Explosion.tscn")

var speed: float
var movement_vector: Vector2
var current_health: float
var bullet_count: int

var rand: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rand.randomize()
	speed = rand.randi_range(speed_min, speed_max)
	movement_vector = Vector2(-speed, 0)
	
	current_health = health
	bullet_count = bullet_limit
	
	var pitch: float = rand.randf_range(climb_angle_limit, dive_angle_limit)
	set_rotation(pitch)
	
	engine_animation.play("approach")
	engine_sound.play()
	
	if rand.randi_range(1, 3) == 1:
		fire_delay_timer.start(rand.randi_range(1, 4))
	

func _process(delta: float) -> void:
	if fire_delay_timer.is_stopped() and bullet_count < bullet_limit:
		fire_delay_timer.start(fire_delay)
		bullet_count -= 1


func _physics_process(delta: float) -> void:
	position += movement_vector.rotated(rotation) * speed * delta


func fire() -> void:
	var b = bullet_scene.instantiate()
	b.global_position = muzzle.global_position
	b.rotation = rotation
	emit_signal("shoot", b)
	fire_delay_timer.start(fire_delay)
	bullet_count -= 1


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	engine_animation.play("receed")


func take_damage(amount: int, body: Area2D) -> void:
	if body.get_parent().is_in_group("Enemy Planes") or body.get_parent().is_in_group("Enemy Bullets"):
		return
		
	if body.get_parent().is_in_group("Player Bullets"):
		body.get_parent().queue_free()
		
	current_health -= amount
	richochet_sound.play_random_sound()
	
	if current_health < health:
		engine_smoke.emitting = true
		var s = (health + 1 - current_health) / health
		engine_smoke.process_material.scale_min = s
		engine_smoke.process_material.scale_max = s
	else:
		engine_smoke.emitting = false
	
	if current_health <=0:
		explode_plane()
		queue_free()

func explode_plane() -> void:
	var e = explosion_scene.instantiate()
	e.global_position = explosion.global_position
	emit_signal("explode_enemy", e)

func _on_explosion_sound_finished() -> void:
	queue_free()


func _on_engine_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "receed":
		queue_free()


func _on_fire_delay_timer_timeout() -> void:
	if bullet_count <= 0:
		return
		
	fire_delay_timer.stop()
	fire()


func _on_fire_start_timer_timeout() -> void:
	pass # Replace with function body.

extends Sprite2D

signal shoot(bullet)
signal explode(explosion)
signal game_over()

@export var health:int  = 3

@export_category("Aircraft")
@export var pitch_speed: float = 0.15
@export var climb_speed: float = 5.0
@export var climb_angle_limit: float = -0.77
@export var dive_angle_limit: float = 1.0

@export_category("Gun")
@export var fire_delay: float = 0.2
@export var cooldown_time: float = 2.0
@export var jam_count: int = 20

@onready var fire_delay_timer = $FireDelayTimer
@onready var cooldown_timer = $CooldownTimer
@onready var engine_sound = $EngineSound
@onready var muzzle = $Muzzle
@onready var gun_smoke = $GunSmokeParticles
@onready var explosion = $Explosion
@onready var hurt_box = $HurtBox
@onready var hit_box = $HitBox
@onready var jam_sound = $JamSoundQueue

var bullet_scene = preload("res://scenes/bullet.tscn")
var explosion_scene = preload("res://scenes/Explosion.tscn")

var bullet_count: int

func _ready() -> void:
	bullet_count = jam_count


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		explode_plane()
		queue_free()
		
	if Input.is_action_pressed("fire") and fire_delay_timer.is_stopped() and bullet_count > 0:
		fire()
	elif Input.is_action_pressed("fire") and fire_delay_timer.is_stopped() and bullet_count == 0:
		jam_fire()
	elif !Input.is_action_pressed("fire") and fire_delay_timer.is_stopped() and cooldown_timer.is_stopped() and bullet_count < jam_count:
		fire_delay_timer.start(fire_delay)
		bullet_count += 1
	elif Input.is_action_just_released("fire") and bullet_count == 0:
		cooldown_timer.start(cooldown_time)
		
	if bullet_count < jam_count / 3:
		gun_smoke.emitting = true
	else:
		gun_smoke.emitting = false
		

func _physics_process(delta) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := Vector2(input_dir.x, input_dir.y).normalized()

	var pitch: float = clampf(rotation + direction.y * pitch_speed * delta * climb_speed, climb_angle_limit, dive_angle_limit)
	set_rotation(pitch)
	position.y += (rotation * climb_speed)
	
	engine_sound.pitch_scale = 1 + pitch / 10


func fire() -> void:
	var b = bullet_scene.instantiate()
	b.global_position = muzzle.global_position
	b.rotation = rotation
	emit_signal("shoot", b)
	cooldown_timer.stop()
	fire_delay_timer.start(fire_delay)
	bullet_count -= 1


func jam_fire() -> void:
	fire_delay_timer.start(fire_delay)
	jam_sound.play_sound()
	cooldown_timer.start(cooldown_time)

func take_damage(amount: int, body: Area2D) -> void:
	if body.get_parent().is_in_group("Player"):
		return
	
	if !body.get_parent().is_in_group("Player Bullets"):
		health -= amount
		
	if health <= 0:
		emit_signal("game_over")
		explode_plane()
		queue_free()

func explode_plane() -> void:
	var e = explosion_scene.instantiate()
	e.global_position = explosion.global_position
	emit_signal("explode", e)


func _on_fire_delay_timer_timeout() -> void:
	pass#fire_delay_timer.stop()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	explode_plane()
	queue_free()


func _on_cooldown_timer_timeout() -> void:
	bullet_count = jam_count

extends AnimatedSprite2D

@export var health:int = 3
@export var climb_angle_limit: float = -0.1
@export var dive_angle_limit: float = 0.1
@export var speed_min:float = 12
@export var speed_max:float = 16

@onready var engine_sound: AudioStreamPlayer = $EngineSound
@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound
@onready var richochet_sound := $RicoshetSoundPool
@onready var hurt_box := $HurtBox
@onready var hit_box := $HitBox
@onready var engine_animation: AnimationPlayer = $EngineAnimation

var speed: float
var movement_vector: Vector2

var rand: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rand.randomize()
	speed = rand.randi_range(speed_min, speed_max)
	movement_vector = Vector2(-speed, 0)
	
	var pitch: float = rand.randf_range(climb_angle_limit, dive_angle_limit)
	set_rotation(pitch)
	
	engine_animation.play("approach")
	engine_sound.play()
	

func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	position += movement_vector.rotated(rotation) * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	engine_animation.play("receed")


func take_damage(amount: int, body: Area2D) -> void:
	if body.get_parent().is_in_group("Enemy Planes"):
		return
		
	if body.get_parent().is_in_group("Player Bullets"):
		body.get_parent().queue_free()
		
	health -= amount
	richochet_sound.play_random_sound()
	
	if health <=0:
		hit_box.queue_free()
		hurt_box.queue_free()
		play()
		engine_sound.stop()
		explosion_sound.play()


func _on_explosion_sound_finished() -> void:
	queue_free()


func _on_engine_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "receed":
		queue_free()

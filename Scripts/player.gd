extends CharacterBody2D

@export_group("Movement Properties")
@export var move_speed: float = 300.0
@export var turn_speed: float = 12.0
@export var acceleration: float = 300.0
@export var friction: float = 1200.0

@export_group("Dash Properties", "dash")
@export var dash_distance: float = 75.0
@export var dash_duration: float = 0.15 # sec
@export var dash_cooldown: float = 1.0 # sec

@onready var sprite: AnimatedSprite2D = %Sprite

var facing_angle: float = 0.0
var last_move_direction: Vector2 = Vector2.RIGHT

var is_rushing: bool = false
var state_must_play: bool = false
var current_animation: StringName = &"idle"

var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.RIGHT
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	facing_angle = sprite.rotation

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction != Vector2.ZERO: last_move_direction = input_direction
	
	if dash_cooldown_timer > 0.0: dash_cooldown_timer -= delta
	
	if Input.is_action_just_pressed("dash"):
		if not is_dashing and dash_cooldown_timer <= 0.0:
			start_dash(input_direction)
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0: is_dashing = false
	elif input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_slide()
	
	var facing_direction := dash_direction if is_dashing else input_direction
	if facing_direction != Vector2.ZERO:
		sprite.flip_h = facing_direction.x < 0.0
		
		var target_angle := atan2(input_direction.y * (-1 if sprite.flip_h else 1), abs(input_direction.x))
		
		if turn_speed <= 0.0: facing_angle = target_angle
		else: facing_angle = lerp_angle(facing_angle, target_angle, turn_speed * delta)
		sprite.rotation = facing_angle
	
	update_movement_animation()

func start_dash(input_direction: Vector2) -> void:
	dash_direction = (input_direction if input_direction != Vector2.ZERO else last_move_direction).normalized()
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	velocity = dash_direction * (dash_distance / dash_duration)
	play_dash()

func get_dash_cooldown_state() -> float:
	return clamp(dash_cooldown_timer / dash_cooldown, 0.0, 1.0)

func update_movement_animation() -> void:
	if state_must_play: return # 1 time animation must play  first
	
	var next_animation: StringName = &"idle"
	if velocity.length() > 5.0: next_animation = &"rush" if is_rushing else &"swim"
	
	if next_animation != current_animation:
		current_animation = next_animation
	sprite.play(current_animation)

func play_dash() -> void:
	current_animation = &"dash"
	state_must_play = true
	FxManager.spawn_bubbles(position)
	sprite.play(current_animation)

func play_hurt() -> void:
	current_animation = &"hurt"
	state_must_play = true
	sprite.play(current_animation)

func _on_sprite_animation_finished() -> void:
	if current_animation == &"dash" or current_animation == &"hurt":
		state_must_play = false
		current_animation = &"idle" # changed in update movement animation in next frame

extends KinematicBody2D
class_name Asteroid

const MAP_MIDDLE = Vector2(512, 288)
const CLOUD_EXPLOSION_EFFECT = preload("res://VFX/Cloud/CloudEffect.tscn")

onready var velocity = Vector2()
var spawn_system # Reference to the spawning system

export (bool) var use_initial_velocity = false
export (Vector2) var initial_velocity

signal add_score(amount)

func _ready():
	z_index = 25 # 5 layers higher than the player
	randomize()
	rotation = rand_range(0, 2 * PI)
	if use_initial_velocity:
		velocity = initial_velocity

func _physics_process(delta):
	move_and_collide(velocity)
	
	# Borders wrap
	var map_size = get_viewport_rect().size
	var border_margin = get_border_margin()
	if position.x < -border_margin:
		position.x = map_size.x + border_margin
	if position.x > map_size.x + border_margin:
		position.x = -border_margin
	if position.y < -border_margin:
		position.y = map_size.y + border_margin
	if position.y > map_size.y + border_margin:
		position.y = -border_margin

func _spawn_explosion_effect():
	var explosion_vfx = CLOUD_EXPLOSION_EFFECT.instance()
	get_parent().add_child(explosion_vfx)
	explosion_vfx.global_position = global_position
	explosion_vfx.z_index = z_index + 1
	return explosion_vfx

func get_points_value() -> int:
	# Override
	return 0

func hit(_damage: int = 1) -> void:
	# Override
	pass

func get_border_margin() -> int:
	# Override
	return 90

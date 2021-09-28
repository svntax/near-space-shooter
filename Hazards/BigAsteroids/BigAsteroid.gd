extends Asteroid

const ASTEROID_SCENES = [
	preload("res://Hazards/SmallAsteroids/SmallAsteroid01.tscn"),
	preload("res://Hazards/SmallAsteroids/SmallAsteroid02.tscn"),
]

onready var hp = 4

func get_points_value() -> int:
	return 50

func hit(damage: int = 1) -> void:
	hp -= damage
	if hp <= 0:
		hide()
		$ExplosionSound.play()
		_spawn_asteroids()
		var explosion = _spawn_explosion_effect()
		explosion.scale = Vector2(2, 2)
		explosion.play_effect()
		emit_signal("add_score", get_points_value())
		# Disable collision
		layers = 0
	else:
		$HitSound.play()

func _spawn_asteroids() -> void:
	for i in range(2):
		call_deferred("_spawn_small_asteroid")

func _spawn_small_asteroid() -> void:
	var choice = randi() % ASTEROID_SCENES.size()
	var asteroid = ASTEROID_SCENES[choice].instance()
	get_parent().add_child(asteroid)
	asteroid.global_position = global_position
	var new_asteroid_speed = rand_range(1, 2)
	var angle = rand_range(0, 2 * PI)
	asteroid.velocity = Vector2(new_asteroid_speed, 0).rotated(angle)
	
	if spawn_system != null:
		asteroid.connect("add_score", spawn_system, "_on_asteroid_destroyed")
		asteroid.spawn_system = spawn_system

func get_border_margin() -> int:
	return 90

func _on_ExplosionSound_finished():
	queue_free()

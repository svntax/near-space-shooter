extends Node2D

enum AsteroidTypes {BIG}

const BIG_ASTEROIDS = [
	preload("res://Hazards/BigAsteroids/BigAsteroid01.tscn"),
	preload("res://Hazards/BigAsteroids/BigAsteroid02.tscn"),
	preload("res://Hazards/BigAsteroids/BigAsteroid03.tscn"),
	preload("res://Hazards/BigAsteroids/BigAsteroid04.tscn")
]

onready var active = false

onready var spawn_timer = $SpawnTimer

func start_spawning() -> void:
	randomize()
	spawn_timer.start()
	active = true

func stop_spawning() -> void:
	spawn_timer.stop()
	active = false

func spawn_big_asteroid() -> void:
	var spawn_choice = randi() % 4
	var asteroid = _spawn_asteroid(AsteroidTypes.BIG, spawn_choice)
	var new_asteroid_speed = rand_range(0.4, 1)
	# Move towards the middle area
	var target_pos = Asteroid.MAP_MIDDLE + Vector2(rand_range(-100, 100), rand_range(-100, 100))
	var angle = target_pos.angle_to_point(asteroid.global_position)
	asteroid.velocity = Vector2(new_asteroid_speed, 0).rotated(angle)

func _spawn_asteroid(type: int, side: int) -> Asteroid:
	var asteroid
	var spawn_points_root
	if type == AsteroidTypes.BIG:
		asteroid = BIG_ASTEROIDS[randi() % BIG_ASTEROIDS.size()].instance()
		spawn_points_root = $SpawnPointsBig
	# If the spawning system should spawn more types of asteroids, handling for
	# that can go here
	add_child(asteroid)
	
	asteroid.spawn_system = self
	asteroid.connect("add_score", self, "_on_asteroid_destroyed")
	
	var pos1 = Vector2()
	var pos2 = Vector2()
	if side == 0: # Top side
		pos1 = spawn_points_root.get_node("TopLeft").global_position
		pos2 = spawn_points_root.get_node("TopRight").global_position
	elif side == 1: # Left side
		pos1 = spawn_points_root.get_node("TopLeft").global_position
		pos2 = spawn_points_root.get_node("BottomLeft").global_position
	elif side == 2: # Right side
		pos1 = spawn_points_root.get_node("TopRight").global_position
		pos2 = spawn_points_root.get_node("BottomRight").global_position
	elif side == 3: # Bottom side
		pos1 = spawn_points_root.get_node("BottomLeft").global_position
		pos2 = spawn_points_root.get_node("BottomRight").global_position
	
	var spawn_pos = Vector2(rand_range(pos1.x, pos2.x), rand_range(pos1.y, pos2.y))
	asteroid.global_position = spawn_pos
	
	return asteroid

func _on_asteroid_destroyed(value: int) -> void:
	var game_root = get_parent()
	game_root.game_ui.add_score(value)

func _on_SpawnTimer_timeout():
	if active:
		# Spawn a big asteroid every 10 seconds
		spawn_big_asteroid()
		spawn_timer.start(10)

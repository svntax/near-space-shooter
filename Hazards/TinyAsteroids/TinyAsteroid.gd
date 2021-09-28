extends Asteroid

func get_points_value() -> int:
	return 5

func hit(damage: int = 1) -> void:
	$HitSound.play()
	hide()
	emit_signal("add_score", get_points_value())
	layers = 0

func get_border_margin() -> int:
	return 16

func _on_HitSound_finished():
	queue_free()

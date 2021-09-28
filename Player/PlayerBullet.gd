extends Area2D

onready var cloud_explosion_effect = load("res://VFX/Cloud/CloudEffect.tscn")

onready var velocity = Vector2()

func _physics_process(delta):
	position += velocity * delta

func _on_PlayerBullet_body_entered(body):
	if body.has_method("hit"):
		body.hit()
		_spawn_hit_effect()
		queue_free()

func _spawn_hit_effect() -> void:
	var explosion_vfx = cloud_explosion_effect.instance()
	get_parent().add_child(explosion_vfx)
	explosion_vfx.global_position = global_position
	explosion_vfx.play_short_effect()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

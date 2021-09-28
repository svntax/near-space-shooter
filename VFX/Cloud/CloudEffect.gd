extends Node2D

func play_effect() -> void:
	$AnimationPlayer.play("explosion")

func play_short_effect() -> void:
	$AnimationPlayer.play("explosion_short")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()

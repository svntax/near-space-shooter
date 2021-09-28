extends Node2D

onready var game_ui = $UILayer/GameUI
onready var animation_player = $AnimationPlayer
onready var spawn_system = $SpawnSystem
onready var player = $Player

func _ready():
	game_ui.set_lives(3)
	game_ui.set_score(0)
	animation_player.play("intro")

func _on_Player_life_lost(remaining_lives: int):
	if remaining_lives < 0:
		animation_player.play("game_over")
		spawn_system.stop_spawning()
	else:
		game_ui.remove_life()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro":
		spawn_system.start_spawning()
		player.state = player.States.ALIVE

extends Control

onready var lives = 3
onready var score = 0

func remove_life() -> void:
	set_lives(lives - 1)

func set_lives(amount: int) -> void:
	lives = amount
	var count = 0
	for icon in $LivesContainer.get_children():
		if count < amount:
			icon.show()
		else:
			icon.hide()
		count += 1

func set_score(value: int) -> void:
	$Score.set_text("Score: " + str(value))
	score = value

func add_score(value: int) -> void:
	set_score(score + value)

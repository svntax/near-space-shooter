extends VBoxContainer

func _on_RestartButton_pressed():
	get_tree().reload_current_scene()

func _on_ExitButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn")

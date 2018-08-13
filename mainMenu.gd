extends Node2D

func _on_Button2_button_up():
	get_tree().quit()


func _on_Button_button_up():	
	get_tree().change_scene("res://scene.tscn")

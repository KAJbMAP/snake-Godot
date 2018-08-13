extends Button
export(bool) var toLeft 
export(float) var speed = 1

func _ready():	
	$idleAnim.playback_speed = speed
	if toLeft == true:
		$idleAnim.play("idle")
	else:
		$idleAnim.play_backwards("idle")	

func _on_Button_mouse_entered():
	$zoomAnim.play("scale")


func _on_Button_mouse_exited():
	$zoomAnim.play("unScale")

extends Node2D

enum Dir {LEFT, UP, RIGHT, DOWN}

var segments = []
onready var segmentScene = load("res://scenes/segment.tscn")
onready var appleScene = load("res://scenes/apple.tscn")
onready var applePartScene = load("res://scenes/aplePart.tscn")

var segmentPixelSize = Vector2(32,32)
var worldSize = Vector2(20,15)
var worldPixelSize = segmentPixelSize*worldSize

var applePart
var apple
var newDir
var directions = []
var score = 0

var played = false
var deathAnimIndex = 0

var _debugDirs = {LEFT : "Left", UP : "Up", RIGHT : "Right", DOWN : "Down"}

func _ready():	
	randomize()
	spawnApple()	
	spawnSnake()
	apple.position = Vector2(randi()%int(worldSize.x)*segmentPixelSize.x,randi()%int(worldSize.y)*segmentPixelSize.y)
	$Panel/restartBtn.hide()

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_left"):
		if newDir != RIGHT:
			newDir = LEFT
	elif Input.is_action_just_pressed("ui_up"):
		if newDir != DOWN:
			newDir = UP
	elif Input.is_action_just_pressed("ui_right"):
		if newDir != LEFT:
			newDir = RIGHT
	elif Input.is_action_just_pressed("ui_down"):
		if newDir != UP:
			newDir = DOWN	
#	print(_debugDirs[newDir])

func _on_Timer_timeout():
	#move snake
	for i in range(segments.size()-1, 0, -1):
		segments[i].position = segments[i-1].position
		directions[i] = directions[i-1]
	directions[0] = newDir
	
	#move head
	match newDir:
		LEFT:
			segments[0].position.x += -segmentPixelSize.x 
			if segments[0].position.x < 0:
				segments[0].position.x+=worldPixelSize.x
			setFrame(0,8)
		UP:
			segments[0].position.y += -segmentPixelSize.y
			if segments[0].position.y < 0:
				segments[0].position.y+=worldPixelSize.y
			setFrame(0,3)
		RIGHT:
			segments[0].position.x += segmentPixelSize.x
			if segments[0].position.x >= worldPixelSize.x:
				segments[0].position.x-=worldPixelSize.x
			setFrame(0,4)
		DOWN:
			segments[0].position.y += segmentPixelSize.y
			if segments[0].position.y >= worldPixelSize.y:
				segments[0].position.y-=worldPixelSize.y
			setFrame(0,9)
	#setting frames for segments
	for i in range(segments.size()-2, 0, -1):
		#body
		if directions[i] == directions[i-1]:
			if directions[i] == LEFT || directions[i] == RIGHT:
				setFrame(i,1)
			if (directions[i] == UP || directions[i] == DOWN):
				setFrame(i,7)
		#turns
		else:
			if directions[i] == LEFT && directions[i-1] == DOWN || directions[i] == UP && directions[i-1] == RIGHT: 
				setFrame(i,0)
			if directions[i] == UP && directions[i-1] == LEFT || directions[i] == RIGHT && directions[i-1] == DOWN:
				setFrame(i,2)
			if directions[i] == DOWN && directions[i-1] == RIGHT || directions[i] == LEFT && directions[i-1] == UP:
				setFrame(i,5)
			if directions[i] == RIGHT && directions[i-1] == UP || directions[i] == DOWN && directions[i-1] == LEFT:
				setFrame(i,12)
	#tail
	if directions[directions.size()-2] == UP:
		setFrame(directions.size()-1,13)
	if directions[directions.size()-2] == RIGHT:
		setFrame(directions.size()-1,14)
	if directions[directions.size()-2] == LEFT:
		setFrame(directions.size()-1,18)
	if directions[directions.size()-2] == DOWN:
		setFrame(directions.size()-1,19)
	
	#eat aple
	if segments[0].position == apple.position:	
		played = true
		score+=1
		$Panel/scoreboard.text = "Score: " + String(score)
		applePart.position = segments[0].position + Vector2(16,16)
		$background/Particles2D.restart()
		segments.append(segmentScene.instance())
		segments.back().set_name("seg"+String(segments.size()-1))
		$background.add_child(segments.back())
		segments.back().position = segments[segments.size()-2].position
		directions.append(directions[directions.size()-1])
		setFrame(directions.size()-1, getFrame(directions.size()-2))
		while true:
			var posCorrect = true
			apple.position = Vector2(randi()%int(worldSize.x)*segmentPixelSize.x,randi()%int(worldSize.y)*segmentPixelSize.y)
			for _seg in segments:
				if _seg.position == apple.position:
					posCorrect = false
					break
			if posCorrect == true:
				break
	for i in range(segments.size()-1):
		if segments[0].position == segments[i].position && i > 0:
			$Tween.interpolate_property($Panel, "rect_position", $Panel.rect_position, Vector2(0,0), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
			$Tween.interpolate_property($"Panel/scoreboard", "rect_position", $Panel/scoreboard.rect_position, Vector2(204,160), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
			$Tween.interpolate_property($"Panel/restartBtn", "self_modulate", Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1) 
			$Tween.start()
			$"Panel/restartBtn".show()
			get_tree().paused = true
			
func spawnSnake():
	if !segments.empty():
		for i in segments:
			i.queue_free()
		segments.clear()
	if !directions.empty():
		directions.clear()
	
	newDir = UP	
	for i in range(3):
		directions.append(UP)
		segments.append(segmentScene.instance())
		segments.back().segNum = 7
		if i == 0:
			segments.back().segNum = 3
		if i == 2:
			segments.back().segNum = 13
		segments.back().set_name("seg"+String(segments.size()-1))
		$background.add_child(segments.back())		
		segments.back().position = Vector2(worldPixelSize.x/2,(worldPixelSize.y/2-16)+(segmentPixelSize.y*i))

func spawnApple():	
	apple = appleScene.instance()
	$background.add_child(apple)
	applePart = applePartScene.instance()
	$background.add_child(applePart)
	
func getFrame(index):
		return segments[index].get_node("snake-Tiles").frame
		
func setFrame(index, _frame):
		segments[index].get_node("snake-Tiles").frame = _frame

func _on_animTimer_timeout():
	if played == true:
		segments[deathAnimIndex].get_node("snake-Tiles/anim").play("deathAnim")
		deathAnimIndex+=1		
		if deathAnimIndex == segments.size():
			deathAnimIndex = 0
			played = false

func _on_Restart_button_up():	
	get_tree().reload_current_scene()
	get_tree().paused = false

extends Node2D

enum Dir {LEFT, UP, RIGHT, DOWN}

var segments = []
onready var segmentScene = load("res://segment.tscn")
onready var appleScene = load("res://apple.tscn")
onready var applePartScene = load("res://aplePart.tscn")

var applePart
var apple
var newDir
var directions = []

var played = false
var deathAnimIndex = 0

var _debugDirs = {LEFT : "Left", UP : "Up", RIGHT : "Right", DOWN : "Down"}

func _ready():
	randomize()
	spawnApple()	
	spawnSnake()
	apple.position = Vector2(randi()%20*32,randi()%16*32)

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
	
	for i in range(segments.size()-1, 0, -1):
		segments[i].position = segments[i-1].position
		directions[i] = directions[i-1]
	directions[0] = newDir
	
	match newDir:
		LEFT:
			segments[0].position += Vector2(-32,0)
			if segments[0].position.x < 0:
				segments[0].position.x+=640
			setFrame(0,8)
		UP:
			segments[0].position += Vector2(0,-32)
			if segments[0].position.y < 0:
				segments[0].position.y+=512
			setFrame(0,3)
		RIGHT:
			segments[0].position += Vector2(32,0)
			if segments[0].position.x >= 640:
				segments[0].position.x-=640
			setFrame(0,4)
		DOWN:
			segments[0].position += Vector2(0,32)
			if segments[0].position.y >= 512:
				segments[0].position.y-=512
			setFrame(0,9)
	
	for i in range(segments.size()-2, 0, -1):
		#Туловище
		if directions[i] == directions[i-1]:
			if directions[i] == LEFT || directions[i] == RIGHT:
				setFrame(i,1)
			if (directions[i] == UP || directions[i] == DOWN):
				setFrame(i,7)
		#Повороты
		else:
			if directions[i] == LEFT && directions[i-1] == DOWN || directions[i] == UP && directions[i-1] == RIGHT: 
				setFrame(i,0)
			if directions[i] == UP && directions[i-1] == LEFT || directions[i] == RIGHT && directions[i-1] == DOWN:
				setFrame(i,2)
			if directions[i] == DOWN && directions[i-1] == RIGHT || directions[i] == LEFT && directions[i-1] == UP:
				setFrame(i,5)
			if directions[i] == RIGHT && directions[i-1] == UP || directions[i] == DOWN && directions[i-1] == LEFT:
				setFrame(i,12)
	#Хвост
	if directions[directions.size()-2] == UP:
		setFrame(directions.size()-1,13)
	if directions[directions.size()-2] == RIGHT:
		setFrame(directions.size()-1,14)
	if directions[directions.size()-2] == LEFT:
		setFrame(directions.size()-1,18)
	if directions[directions.size()-2] == DOWN:
		setFrame(directions.size()-1,19)
	
	if segments[0].position == apple.position:	
		played = true
		applePart.position = segments[0].position + Vector2(16,16)
		$Particles2D.restart()
		segments.append(segmentScene.instance())
		segments.back().set_name("seg"+String(segments.size()-1))
		add_child(segments.back())
		segments.back().position = segments[segments.size()-2].position
		directions.append(directions[directions.size()-1])
		setFrame(directions.size()-1, getFrame(directions.size()-2))
		while true:
			var posCorrect = true
			apple.position = Vector2(randi()%20*32,randi()%16*32)
			for _seg in segments:
				if _seg.position == apple.position:
					posCorrect = false
					break
			if posCorrect == true:
				break
				
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
		add_child(segments.back())		
		segments.back().position = Vector2(640/2,(512/2)+(32*i))

func spawnApple():	
	apple = appleScene.instance()
	add_child(apple)
	applePart = applePartScene.instance()
	add_child(applePart)
	
func getFrame(index):
#		return get_node("seg"+String(index)+"/snake-Tiles").frame
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

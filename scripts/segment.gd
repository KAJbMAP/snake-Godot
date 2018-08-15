extends Node2D

export var segNum = 0

func _on_segment_tree_entered():
	$"snake-Tiles".vframes = 4
	$"snake-Tiles".hframes = 5
	$"snake-Tiles".frame = segNum
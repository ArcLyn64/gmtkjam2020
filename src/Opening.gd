extends Node

onready var dungeon = preload("res://map/Dungeon.tscn")

func _ready():
	$Dialogue.start("res://dialogue/opening.json")

func _process(delta):
	if $Dialogue.cur_state == $Dialogue.STATE.hidden or Input.is_action_just_pressed("z"):
		get_tree().change_scene_to(dungeon)

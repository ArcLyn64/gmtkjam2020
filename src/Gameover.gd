extends Node

onready var menu = preload("res://MainMenu.tscn")

func _ready():
	$Dialogue.start("res://dialogue/gameover.json")

func _process(delta):
	if $Dialogue.cur_state == $Dialogue.STATE.hidden or Input.is_action_just_pressed("z"):
		get_tree().change_scene_to(menu)

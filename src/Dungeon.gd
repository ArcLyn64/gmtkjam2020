extends Node2D

# world things
onready var mapgen = $MapGen
onready var tilemap = $TileMap
onready var enemies = $Enemies
onready var chests = $Chests
onready var exit : Area2D = $Exit
onready var dialogue = $UI/Dialogue

# party things
onready var party = $Party
onready var player = $Party/Player

var cur_level = 0
enum STATE{
	roaming,
	battle,
	dialogue,
	paused,
	loading
}
var cur_state = STATE.loading

var astar_data = null

func _ready():
	randomize()
	mapgen.init(self, tilemap, party, enemies, chests, exit)
	for child in party.get_children():
		child.init(self, tilemap, party, enemies, chests, exit)
	go_to_next_level()

func _physics_process(delta):
	match cur_state:
		STATE.loading:
			pass
		STATE.paused:
			pass
		STATE.roaming:
			for child in party.get_children() :
				child.call("roaminghandler", delta)
			for child in enemies.get_children() :
				child.call("roaminghandler", delta, world_to_map(player.global_position), tilemap)
#			for child in party.get_children() + enemies.get_children():
#				child.call("roaminghandler", delta)
		STATE.battle:
			pass
		STATE.dialogue:
			pass

func world_to_map(pos: Vector2):
	var vcoords = tilemap.world_to_map(pos)
	var coords = [int(round(vcoords.x)), int(round(vcoords.y))]
	return coords

func _on_Exit_body_entered(body):
	if(body.get_name() == "Player"):
		go_to_next_level()

func go_to_next_level():
	cur_state = STATE.loading
	for child in chests.get_children() + enemies.get_children():
		child.queue_free()
	yield(get_tree().create_timer(1.0), "timeout")
	astar_data = mapgen.generate_world(cur_level)
	for child in enemies.get_children() + party.get_children():
		child.update_astar(astar_data)
	cur_level += 1
	dialogue.start("res://dialogue/quips/test.json")
	cur_state = STATE.roaming

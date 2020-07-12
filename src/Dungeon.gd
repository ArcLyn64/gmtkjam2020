extends Node2D

const CURTAIN_RIGHT_BOUND = 587
const CURTAIN_LEFT_BOUND = -217
const CURTAIN_CLOSED_BOUND = 250
const CURTAIN_SPEED = 50

# world things
onready var mapgen = $MapGen
onready var tilemap = $TileMap
onready var enemies = $Enemies
onready var chests = $Chests
onready var battles = $Battles
onready var exit : Area2D = $Exit
onready var dialogue = $UI/Dialogue
onready var curtain = $UI/Curtain

# party things
onready var party = $Party
onready var player = $Party/Player

var cur_level = 0
enum STATE{
	roaming,
	paused,
	loading
}
var cur_state = STATE.loading
var foreground_color : Color = Color.blue
var background_color : Color = Color.coral

var astar_data = null

func _ready():
	randomize()
	mapgen.init(self, tilemap, party, enemies, chests, exit)
	for child in party.get_children():
		child.init(self, tilemap, party, enemies, chests, exit)
	for child in battles.get_children():
		child.init(self, tilemap, party, enemies, chests, exit)
	go_to_next_level()

func _physics_process(delta):
	match cur_state:
		STATE.loading:
			close_curtain(delta)
		STATE.paused:
			pass
		STATE.roaming:
			open_curtain(delta)
			for child in party.get_children() + enemies.get_children():
				child.call("roaminghandler", delta)
#			for child in party.get_children() + enemies.get_children():
#				child.call("roaminghandler", delta)

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
	for child in enemies.get_children():
		child.init(self, tilemap, party, enemies, chests, exit)
		child.update_astar(astar_data)
	for child in party.get_children():
		child.update_astar(astar_data)
	change_foreground_color(foreground_color)
	change_background_color(background_color)

	cur_level += 1
	dialogue.start("res://dialogue/quips/test.json")
	cur_state = STATE.roaming

func close_curtain(delta):
	if curtain.get_position()[0] < CURTAIN_LEFT_BOUND:
		curtain.set_position(Vector2(CURTAIN_RIGHT_BOUND, curtain.get_position()[1]))
	elif curtain.get_position()[0] > CURTAIN_CLOSED_BOUND:
		curtain.set_position(curtain.get_position()+Vector2(-CURTAIN_SPEED,0))

func open_curtain(delta):
	if curtain.get_position()[0] > CURTAIN_CLOSED_BOUND:
		curtain.set_position(Vector2(CURTAIN_CLOSED_BOUND, curtain.get_position()[1]))
	elif curtain.get_position()[0] > CURTAIN_LEFT_BOUND:
		curtain.set_position(curtain.get_position()+Vector2(-CURTAIN_SPEED,0))

func change_foreground_color(color: Color):
	# tileset
	var tileset = tilemap.get_tileset()
	for tile in tileset.get_tiles_ids():
		tileset.tile_set_modulate(tile, color)
	# sprites
	for child in party.get_children() + chests.get_children() + enemies.get_children():
		child.change_color(color)
	exit.change_color(color)

func change_background_color(color: Color):
	VisualServer.set_default_clear_color(color)

func init_battle(position):
	for battle in battles.get_children():
		if !battle.fighting:
			battle.global_position = position
			yield(get_tree().create_timer(0.5), "timeout")
			battle.start_battle()
			return

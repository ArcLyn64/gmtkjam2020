extends PanelContainer

onready var zact = $Actions/ZAct
onready var zlbl = $Actions/ZAct/ZLbl
onready var zind = $Actions/ZAct/ZInd
onready var xact = $Actions/XAct
onready var xlbl = $Actions/XAct/XLbl
onready var xind = $Actions/XAct/XInd
onready var cact = $Actions/CAct
onready var clbl = $Actions/CAct/CLbl
onready var cind = $Actions/CAct/CInd
onready var vact = $Actions/VAct
onready var vlbl = $Actions/VAct/VLbl
onready var vind = $Actions/VAct/VInd

onready var dungeon = preload("res://map/Dungeon.tscn")
onready var opening = preload("res://Opening.tscn")

const VALID_COLOR = Color.black
const INVALID_COLOR = Color.gray

const VOLUME_INC = 1

var menus = null

var actions = {
	"z": null,
	"x": null,
	"c": null,
	"v": null
}

var main_menu = {
	"z": "Start",
	"x": "Volume +",
	"c": "Volume -",
	"v": "Quit"
}

var item_index = 0

func _ready():
	menus = {
		"z": {
			"label": zlbl,
			"indicator": zind
		},
		"x": {
			"label": xlbl,
			"indicator": xind
		},
		"c": {
			"label": clbl,
			"indicator": cind
		},
		"v": {
			"label": vlbl,
			"indicator": vind
		}
	}

func _process(delta):
	# draw menu
	create_menu()
	action_handler(delta)

func action_handler(delta):
	if Input.is_action_just_pressed("z"):
		do_action("z")
	elif Input.is_action_just_pressed("x"):
		do_action("x")
	elif Input.is_action_just_pressed("c"):
		do_action("c")
	elif Input.is_action_just_pressed("v"):
		do_action("v")

func create_menu():
	var binds = main_menu
	# assign text
	for bind in binds:
		actions[bind] = binds[bind]
		menus[bind]["label"].text = binds[bind]

func do_action(bind):
	match actions[bind]:
		"Start":
			get_tree().change_scene_to(opening)
		"Volume +":
			var bus = AudioServer.get_bus_index("Master")
			var cur_volume = AudioServer.get_bus_volume_db(bus)
			AudioServer.set_bus_volume_db(bus, cur_volume + VOLUME_INC)
		"Volume -":
			var bus = AudioServer.get_bus_index("Master")
			var cur_volume = AudioServer.get_bus_volume_db(bus)
			AudioServer.set_bus_volume_db(bus, cur_volume - VOLUME_INC)
		"Quit":
			get_tree().quit()

func format_skill_cost(cost) -> String:
	var ret = ""
	if cost["hp"] != 0:
		ret += str(cost["hp"]) + " hp"
	if cost["sp"] != 0:
		if ret != "":
			ret += ", "
		ret += str(cost["sp"]) + " sp"
	return ret

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

const VALID_COLOR = Color.black
const INVALID_COLOR = Color.gray

var menus = null

var valid = {
	"z": false,
	"x": false,
	"c": false,
	"v": false
}

var actions = {
	"z": null,
	"x": null,
	"c": null,
	"v": null
}

var main_menu = {
	"z": "interact",
	"x": "level up",
	"c": "hide",
	"v": "quit"
}

var battle = null
var combatant: Combatant = null
var player = null

var bind_to_add = null

var item_index = 0

enum MENUSTATE{
	main,
	level,
	replace,
	inactive,
	transition
}
var menustate = MENUSTATE.inactive

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
	disable()

func init(pl):
	player = pl
	combatant = pl.combatant_data

func disable():
	menustate = MENUSTATE.inactive
	hide()

func enable():
	menustate = MENUSTATE.main
	show()

func _process(delta):
	if combatant.in_battle:
		disable()
		return
	# draw menu
	match menustate:
		MENUSTATE.main:
			create_menu(main_menu)
		MENUSTATE.level:
			create_menu(combatant.level_skills)
		MENUSTATE.replace:
			create_menu(combatant.skills)
		MENUSTATE.inactive:
			if Input.is_action_just_pressed("z") or Input.is_action_just_pressed("x") or Input.is_action_just_pressed("c") or Input.is_action_just_pressed("v"):
				yield(get_tree().create_timer(0.1), "timeout")
				enable()
	# check valid/invalid
	for bind in valid:
		var indicator: ColorRect = menus[bind]["indicator"]
		if valid[bind]:
			indicator.color = VALID_COLOR
		else:
			indicator.color = INVALID_COLOR
	# take input
	if menustate != MENUSTATE.inactive:
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

func create_menu(binds: Dictionary):
	# assign text
	for bind in binds:
		actions[bind] = binds[bind]
		var isvalid = false
		if binds[bind] == null:
			menus[bind]["label"].text = ""
		elif typeof(binds[bind]) == TYPE_DICTIONARY:
			# replace with skill name
			var info = combatant.skill_display_info(bind)
			menus[bind]["label"].text = info["name"] + "\n" + format_skill_cost(info["cost"])
			isvalid = true
		elif menustate == MENUSTATE.level:
			menus[bind]["label"].text = binds[bind]
			isvalid = true
		elif binds[bind] == "back":
			# this is toss skill
			menus[bind]["label"].text = "no replace"
			isvalid = true # you can always use items
		else:
			menus[bind]["label"].text = binds[bind]
			isvalid = check_option_valid(binds[bind])
		valid[bind] = isvalid

func check_option_valid(action):
	if combatant.dead():
		return false # can't do anything when dead
	match action:
		"interact":
			return player.get_interact_target() != null # TODO: set up interaction
		"level up":
			return combatant.check_level_up()
		"hide":
			return true # can always hide
		"quit":
			return true # can always quit

func do_action(bind):
	if(!valid[bind]):
		return
	$SelectSound.play()
	if typeof(actions[bind]) == TYPE_DICTIONARY:
		combatant.level_up(bind_to_add, bind)
		bind_to_add = null
		menustate = MENUSTATE.main
	elif actions[bind] == "back":
		combatant.level_up(bind_to_add, bind)
		bind_to_add = null
		menustate = MENUSTATE.main
	elif menustate == MENUSTATE.level:
		print("got here")
		bind_to_add = bind
		menustate = MENUSTATE.replace
	else:
		match actions[bind]:
			"interact":
				player.interact()
			"level up":
				menustate = MENUSTATE.level
			"hide":
				disable()
			"quit":
				player.scene_root.return_to_menu()

func format_skill_cost(cost) -> String:
	var ret = ""
	if cost["hp"] != 0:
		ret += str(cost["hp"]) + " hp"
	if cost["sp"] != 0:
		if ret != "":
			ret += ", "
		ret += str(cost["sp"]) + " sp"
	return ret

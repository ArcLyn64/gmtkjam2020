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

var battle = null
var combatant: Combatant = null

var item_index = 0

enum MENUSTATE{
	main,
	skill,
	ask,
	item,
	inactive
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

func init(bat, cbt):
	battle = bat
	combatant = cbt

func disable():
	menustate = MENUSTATE.inactive
	hide()

func enable():
	menustate = MENUSTATE.main
	show()

func _process(delta):
	# draw menu
	match menustate:
		MENUSTATE.main:
			create_menu(combatant.actions)
		MENUSTATE.skill:
			create_menu(combatant.skills)
		MENUSTATE.ask:
			create_menu(combatant.requests)
		MENUSTATE.item:
			create_menu(combatant.item)
	# check valid/invalid
	for bind in valid:
		var indicator: ColorRect = menus[bind]["indicator"]
		if valid[bind]:
			indicator.color = VALID_COLOR
		else:
			indicator.color = INVALID_COLOR
	# take input
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
			isvalid = check_skill_valid(bind)
		elif binds[bind] == "use":
			# replace with item name
			menus[bind]["label"].text = combatant.item_title(item_index)
			isvalid = true # you can always use items
		else:
			menus[bind]["label"].text = binds[bind]
			isvalid = check_option_valid(binds[bind])
		valid[bind] = isvalid

func check_option_valid(action):
	if combatant.dead():
		return false # can't do anything when dead
	match action:
		"back":
			return true # you can always go back
		"skill":
			return true # you can always open the skill menu
		"ask":
			return true # you can always open the ask menu
		"item":
			return combatant.items.size() > 0 # cannot open without items
		"flee":
			return true # you can always flee
		"defend":
			return battle.selected_ally().combatant != combatant # cannot ask self
		"heal":
			return battle.selected_ally().combatant != combatant # cannot ask self
		"run":
			return battle.selected_ally().combatant != combatant # cannot ask self
		"next":
			return true # you can always scroll forward
		"prev":
			return true # you can always scroll backward

func check_skill_valid(bind):
	var cost = combatant.skill_cost(bind)
	return cost["hp"] < combatant.hp and cost["sp"] <= combatant.sp

func do_action(bind):
	if(!valid[bind]):
		return
	
	if typeof(actions[bind]) == TYPE_DICTIONARY:
		var skill_name = actions[bind]["name"]
		var skillinfo = SkillCompendium.compendium[skill_name]
		if skillinfo["target"] == SkillCompendium.TARGET.ALLY:
			combatant.cast_skill(bind, battle.selected_ally().combatant)
		else:
			combatant.cast_skill(bind, battle.selected_enemy().combatant)
		menustate = MENUSTATE.main
	elif actions[bind] == "use":
		var item = combatant.items[item_index]
		var skill_name = item["name"]
		var skillinfo = SkillCompendium.compendium[skill_name]
		if skillinfo["target"] == SkillCompendium.TARGET.ALLY:
			combatant.use_item(item_index, battle.selected_ally().combatant)
		else:
			combatant.use_item(item_index, battle.selected_enemy().combatant)
		menustate = MENUSTATE.main
	else:
		match actions[bind]:
			"back":
				menustate = MENUSTATE.main
			"skill":
				menustate = MENUSTATE.skill
			"ask":
				menustate = MENUSTATE.ask
			"item":
				menustate = MENUSTATE.item
			"flee":
				battle.flee(combatant)
			"defend":
				menustate = MENUSTATE.main
				pass #TODO
			"heal":
				menustate = MENUSTATE.main
				pass #TODO
			"run":
				menustate = MENUSTATE.main
				pass #TODO
			"next":
				item_index = (item_index + 1) % combatant.items.size()
			"prev":
				item_index = (item_index + combatant.items.size() - 1) % combatant.items.size()

func format_skill_cost(cost) -> String:
	var ret = ""
	if cost["hp"] != 0:
		ret += str(cost["hp"]) + " hp"
	if cost["sp"] != 0:
		if ret != "":
			ret += ", "
		ret += str(cost["sp"]) + " sp"
	return ret

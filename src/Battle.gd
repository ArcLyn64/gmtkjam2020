extends Node2D

onready var allylist = $Menu/Allies/VBoxContainer
onready var enemylist = $Menu/Enemies/VBoxContainer
onready var area = $Area2D
onready var menu = $Menu
onready var actionmenu = $Menu/ActionMenu
onready var CombatantLabel = preload("res://ui/CombatantLabel.tscn")

var scene_root = null
var tilemap = null
var party = null
var enemies = null
var chests = null
var exit = null

const MAX_COMBATANTS = 4 # on each side

const SELECTED_COLOR = Color.red
const IDLE_COLOR = Color(0,0,0,0)

var ally_select = 0
var enemy_select = 0

var ready = false
var fighting: bool = false

func hide():
	.hide()
	for child in menu.get_children():
		child.hide()

func show():
	.show()
	for child in menu.get_children():
		child.show()

func init(scn_root, tilemap_ref, party_ref, enemies_ref, chests_ref, exit_ref):
	hide()
	scene_root = scn_root
	tilemap = tilemap_ref
	party = party_ref
	enemies = enemies_ref
	chests = chests_ref
	exit = exit_ref

func start_battle():
	for body in area.get_overlapping_bodies():
		print(body.get_name())
		for child in party.get_children():
			if body == child:
				add_combatant(allylist, child)
		for child in enemies.get_children():
			if body == child:
				add_combatant(enemylist, child)
	update_based_on_player()
	fighting = true

func update_based_on_player():
	if player_present():
		actionmenu.init(self, get_player().combatant)
		actionmenu.enable()
		show()
	else:
		actionmenu.disable()
		hide()

#func _ready():
#	add_item(allylist, "Player")
#	add_item(allylist, "Bow")
#	add_item(enemylist, "Enemy1")
#	add_item(enemylist, "Enemy2")
#	add_item(enemylist, "Enemy3")
#	if player_present():
#		actionmenu.init(self, get_player().combatant)
#		actionmenu.enable()
#		allylist.get_children()[0].select()
#		enemylist.get_children()[0].select()

func wipe_dead():
	var total_xp_allies = 0
	var reselect_flag_e = false
	var reselect_flag_a = false
	for ally in allylist.get_children():
		if ally.combatant.dead():
			if ally == selected_enemy():
				reselect_flag_a = true
			ally.leave_battle()
	for enemy in enemylist.get_children():
		if enemy.combatant.dead():
			total_xp_allies += enemy.combatant.xp_reward()
			if enemy == selected_enemy():
				reselect_flag_e = true
			enemy.leave_battle()
	for ally in allylist.get_children():
		ally.combatant.xp += total_xp_allies / allylist.get_child_count()
	if reselect_flag_a:
		allylist.get_children()[0].select()
	if reselect_flag_e:
		enemylist.get_children()[0].select()

func flee(combatant):
	for ally in allylist.get_children():
		if ally.combatant == combatant:
			ally.leave_battle()
	for enemy in enemylist.get_children():
		if enemy.combatant == combatant:
			enemy.leave_battle()

func get_ally(ind: int) -> CombatantLabel:
	return allylist.get_children()[ind]

func selected_ally() -> CombatantLabel:
	return get_ally(ally_select)

func num_allies() -> int:
	return allylist.get_child_count()

func get_enemy(ind: int) -> CombatantLabel:
	return enemylist.get_children()[ind]

func selected_enemy() -> CombatantLabel:
	return get_enemy(enemy_select)

func num_enemies() -> int:
	return enemylist.get_child_count()

func add_combatant(where, body) -> bool:
	if where.get_child_count() >= MAX_COMBATANTS || !body.enter_battle():
		print("failed to add " + body.get_name())
		return false
	var inst = CombatantLabel.instance()
	inst.init(body)
	where.add_child(inst)
	return true

func reset():
	fighting = false
	for ally in allylist.get_children():
		ally.leave_battle()
	for enemy in enemylist.get_children():
		enemy.leave_battle()
	hide()

func _process(delta):
	if player_present():
		if Input.is_action_just_pressed("move_up"):
			select_up()
		elif Input.is_action_just_pressed("move_down"):
			select_down()
	else:
		actionmenu.disable()
	wipe_dead()
	if (num_allies() == 0 or num_enemies() == 0) and fighting:
		print("battle over!")
		reset()
	if player_present():
		show()
	else:
		hide()

func player_present():
	for ind in range(num_allies()):
		if get_ally(ind).combatant.combatant_name == "Player":
			return true
	return false

func get_player():
	assert(player_present())
	for ind in range(num_allies()):
		if get_ally(ind).combatant.combatant_name == "Player":
			return get_ally(ind)
	return null

func select_down():
	get_ally(ally_select).deselect()
	get_enemy(enemy_select).deselect()
	ally_select = min(ally_select + 1, num_allies() - 1)
	enemy_select = min(enemy_select + 1, num_enemies() - 1) 
	get_ally(ally_select).select()
	get_enemy(enemy_select).select()

func select_up():
	get_ally(ally_select).deselect()
	get_enemy(enemy_select).deselect()
	ally_select = max(ally_select - 1, 0)
	enemy_select = max(enemy_select - 1, 0)
	get_ally(ally_select).select()
	get_enemy(enemy_select).select()

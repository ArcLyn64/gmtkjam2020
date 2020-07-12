extends KinematicBody2D

onready var roamingmenu = $UI/RoamingMenu
onready var interact: Area2D = $Interact

var scene_root = null
var tilemap = null
var party = null
var enemies = null
var chests = null
var exit = null
var astar = null
var astar_points_cache = null

const ACCELERATION = 12
const MAX_SPEED = 50
const FRICTION = 12

const INTERACT_DIST = 10

var velocity = Vector2.ZERO

var scene_color = Color.white

enum STATE{
	roaming,
	battle,
	dead
}
var cur_state = STATE.roaming

var combatant_data = Combatant.new()

func _ready():
	combatant_data.init(get_name())

func enter_battle():
	if combatant_data.in_battle:
		return false
	cur_state = STATE.battle
	combatant_data.enter_battle()
	return true

func get_combatant_data() -> Combatant:
	return combatant_data

func update_astar(astar_update):
	astar = astar_update["astar"]
	astar_points_cache = astar_update["astar_points_cache"]

func init(scn_root, tilemap_ref, party_ref, enemies_ref, chests_ref, exit_ref):
	scene_root = scn_root
	tilemap = tilemap_ref
	party = party_ref
	enemies = enemies_ref
	chests = chests_ref
	exit = exit_ref
	roamingmenu.init(self)

func roaminghandler(delta):
	if Input.is_key_pressed(KEY_P):
		combatant_data.hp = 0
	if combatant_data.dead():
		cur_state = STATE.dead
	match cur_state:
		STATE.roaming:
			handle_move(delta)
		STATE.battle:
			if !combatant_data.in_battle:
				cur_state = STATE.roaming
		STATE.dead:
			$Sprite.set_modulate(Color.black)
			if !combatant_data.dead():
				change_color(scene_color)
				cur_state = STATE.roaming
			else:
				var doomed = true
				for ally in party.get_children():
					if !ally.combatant_data.dead() and ally.combatant_data.can_resurrect(self.combatant_data):
						doomed = false
				if doomed:
					scene_root.game_over()

func position_interact(input_vector):
	interact.set_transform(Transform2D(0, input_vector*INTERACT_DIST))

func handle_move(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		position_interact(input_vector)
		velocity += input_vector * ACCELERATION * delta
		velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide(velocity / delta)

func get_interact_target():
	var bodies = interact.get_overlapping_bodies()
	for body in bodies:
		if body != self:
			return body
	return null

func interact():
	var target = get_interact_target()
	if target in chests.get_children():
		target.crack_chest(scene_root.cur_level)
	if target in party.get_children():
		if combatant_data.can_resurrect(target.combatant_data):
			combatant_data.cast_resurrect(target.combatant_data)

func change_color(color: Color):
	scene_color = color
	$Sprite.set_modulate(color)

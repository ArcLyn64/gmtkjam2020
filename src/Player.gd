extends KinematicBody2D

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

var velocity = Vector2.ZERO

enum STATE{
	roaming,
	battle
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
	print(get_name() + " is raring to go!")
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

func roaminghandler(delta):
	if combatant_data.dead():
		return
	match cur_state:
		STATE.roaming:
			handle_move(delta)
		STATE.battle:
			if !combatant_data.in_battle:
				cur_state = STATE.roaming

func handle_move(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity += input_vector * ACCELERATION * delta
		velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide(velocity / delta)


func change_color(color: Color):
	$Sprite.set_modulate(color)

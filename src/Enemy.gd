extends KinematicBody2D

const PREFIXES = [
	"Red",
	"Blue",
	"Bloody",
	"Quirky",
	"Tired",
	"Spastic",
	"Braindead",
	"Vicious",
	"Deadly",
	"Jovial",
	"Shadow",
	"Dark",
	"Dangerous"
]
const TYPES = [
	"Slime",
	"Drake",
	"Salamander",
	"Machine",
	"Sentry",
	"Knight",
	"Ghost",
	"Wight",
	"Spider",
	"Fly",
	"Baal",
	"Spirit",
	"Curse"
]

const ACCELERATION = 10
const MAX_SPEED = 40
const FRICTION = 10

var velocity = Vector2.ZERO

var scene_root = null
var tilemap = null
var party = null
var enemies = null
var chests = null
var exit = null
var astar = null
var astar_points_cache = null
var sight_points = []

enum STATE{
	alert,
	idle,
	battle,
	await
}
var cur_state = STATE.idle

var combatant_data = Combatant.new()

func enter_battle():
	if combatant_data.in_battle:
		return false
	cur_state = STATE.battle
	combatant_data.enter_battle()
	return true

func level_enemy(levels):
	for _i in range(levels):
		var bind = ["z", "x", "c", "v"][randi() % 4]
		var trade = ["z", "x", "c"][randi() % 3]
		combatant_data.level_up(bind, trade)

func get_combatant_data() -> Combatant:
	return combatant_data

func init(scn_root, tilemap_ref, party_ref, enemies_ref, chests_ref, exit_ref):
	scene_root = scn_root
	tilemap = tilemap_ref
	party = party_ref
	enemies = enemies_ref
	chests = chests_ref
	exit = exit_ref
	roll_name()
	combatant_data.init(get_name())
	combatant_data.set_ai("enemy")

func get_rand_from_arr(arr):
	return arr[randi() % arr.size()]

func roll_name():
	var prefix = get_rand_from_arr(PREFIXES)
	var type = get_rand_from_arr(TYPES)
	set_name(prefix + " " + type)

func update_astar(astar_update):
	astar = astar_update["astar"]
	astar_points_cache = astar_update["astar_points_cache"]

func has_line_of_sight(start_coord, end_coord):
	var x1 = start_coord[0]
	var y1 = start_coord[1]
	var x2 = end_coord[0]
	var y2 = end_coord[1]
	var dx = x2-x1
	var dy = y2-y1
	# get steepness
	var is_steep = abs(dy) > abs(dx)
	var tmp = 0
	# rotate line
	if is_steep:
		tmp = x1
		x1 = y1
		y1 = tmp
		tmp = x2
		x2 = y2
		y2 = tmp
	# swap start and end points if necessary, store swap state
	var swapped = false
	if x1 > x2:
		tmp = x1
		x1 = x2
		x2 = tmp
		tmp = y1
		y1 = y2
		y2 = tmp
		swapped = true
	# recalc diffs
	dx = x2-x1
	dy = y2-y1
	
	# calculate error
	var error = int(dx / 2.0)
	var ystep = 1 if y1 < y2 else -1
	
	# iterate over bounding box generating points between start and end
	var y = y1
	var points = []
	for x in range(x1, x2+1):
		var coord = [y, x] if is_steep else [x, y]
		points.append(coord)
		error -= abs(dy)
		if error < 0:
			y += ystep
			error += dx
	
	if swapped:
		points.invert()
	
	sight_points = []
	for p in points: #TODO find out what's with this 8
		sight_points.append(to_local(Vector2.ONE * 2 + tilemap.map_to_world(Vector2(p[0], p[1]))))
	for p in points:
		if tilemap.get_cell(p[0], p[1]) >= 0:
			return false
	return true

func get_grid_path(start_coord, end_coord):
	var path = astar.get_point_path(astar_points_cache[str(start_coord)], astar_points_cache[str(end_coord)])
	return path

func spot_player():
	for child in party.get_children():
		if child.get_name() == "Player":
			return child

func roaminghandler(delta):
	if combatant_data.dead():
		queue_free()
		return
	var player_loc = world_to_map(spot_player().global_position)
	match cur_state:
		STATE.idle:
			if has_line_of_sight(world_to_map(self.global_position), player_loc):
				var sound = $Sounds.get_child(randi() % $Sounds.get_child_count())
				sound.set_pitch_scale((105.0 - (randi() % 10)) / 100.0)
				sound.play()
				cur_state = STATE.alert
		STATE.alert:
			var path = get_grid_path(world_to_map(self.global_position), player_loc)
			if path.size() > 1:
				move_along_path(path[1])
				var player = hit_player()
				if player != null:
					scene_root.init_battle(global_position)
					cur_state = STATE.await
		STATE.await:
			pass
		STATE.battle:
			if !combatant_data.in_battle:
				cur_state = STATE.alert

func move_along_path(target):
	var coords_unformatted = world_to_map(self.global_position)
	var coords = Vector2(coords_unformatted[0], coords_unformatted[1])
	var input_vector = coords.direction_to(target)
	
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity += input_vector * ACCELERATION
		velocity = velocity.clamped(MAX_SPEED)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	move_and_slide(velocity)

func hit_player():
	for i in range(get_slide_count()):
		var hit = get_slide_collision(i).get_collider().get_name()
		if hit in ["Player", "Bow", "Duals", "Sticks"]:
			return hit
	return null

func world_to_map(pos: Vector2):
	var vcoords = tilemap.world_to_map(pos)
	var coords = [int(round(vcoords.x)), int(round(vcoords.y))]
	return coords

func change_color(color: Color):
	$Sprite.set_modulate(color)

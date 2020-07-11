extends KinematicBody2D


const ACCELERATION = 10
const MAX_SPEED = 40
const FRICTION = 10

var velocity = Vector2.ZERO

var tilemap = null
var astar = null
var astar_points_cache = null
var sight_points = []

enum STATE{
	alert,
	idle
}
var cur_state = STATE.idle

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

#func _draw():
#	for sp in sight_points:
#		draw_circle(sp, 4, Color.red)

func get_grid_path(start_coord, end_coord):
	var path = astar.get_point_path(astar_points_cache[str(start_coord)], astar_points_cache[str(end_coord)])
	return path

func roaminghandler(delta, player_loc, tilemap_ref):
	tilemap = tilemap_ref
	match cur_state:
		STATE.idle:
			if has_line_of_sight(world_to_map(self.global_position), player_loc):
				cur_state = STATE.alert
		STATE.alert:
			var path = get_grid_path(world_to_map(self.global_position), player_loc)
			if path.size() > 1:
				move_along_path(path[1])

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

func world_to_map(pos: Vector2):
	var vcoords = tilemap.world_to_map(pos)
	var coords = [int(round(vcoords.x)), int(round(vcoords.y))]
	return coords

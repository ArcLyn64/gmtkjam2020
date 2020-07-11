extends Node2D

var level = 1

var scene_root = null
var tilemap = null
var party = null
var enemies = null
var chests = null
var exit = null

onready var rooms_texture_data = preload("res://sprites/maps.png").get_data()
onready var astar = AStar2D.new()
var astar_points_cache = {}

var chest = preload("res://objects/Chest.tscn")
var enemy = preload("res://actors/Enemy.tscn")

const START_ROOM_COUNT = 5
const ROOM_COUNT_INCREASE_RATE = 1.1
const EXIT_ROOM_TYPE_IND = 0
const START_ROOM_TYPE_IND = 1

const CELL_SIZE = 16
const ROOMS_SIZE = 8
const ROOM_DATA_IMAGE_ROW_LEN = 4
const NUM_ROOM_TYPES = 12

const NUM_WALL_TYPES = 1

const COLOR_CODE = {
	"Wall" : Color.white,
	"Blank" : Color.black,
	"Enemy" : Color.red,
	"Chest" : Color.green,
	"Exit" : Color.blue,
	"Spawn" : Color.magenta
}

func init(scn_root, tilemap_ref, party_ref, enemies_ref, chests_ref, exit_ref):
	scene_root = scn_root
	tilemap = tilemap_ref
	party = party_ref
	enemies = enemies_ref
	chests = chests_ref
	exit = exit_ref

func generate_world(cur_level):
	level = cur_level
	# empty the previous floor entirely and generate the next one
	tilemap.clear()
	for child in chests.get_children() + enemies.get_children():
		child.queue_free()
	astar.clear()
	var rooms_data = generate_rooms_data()
	var spawn_locations = generate_rooms(rooms_data)
	generate_objects(spawn_locations)
	return {
		"astar": astar,
		"astar_points_cache": astar_points_cache
	}

func generate_rooms_data() -> Dictionary:
	var room_count = int(START_ROOM_COUNT * pow(ROOM_COUNT_INCREASE_RATE, level))
	# we start with our starting room - duh
	var rooms_data = {
		str([0,0]):{"type": START_ROOM_TYPE_IND, "coords":[0,0]}
	}
	
	# make the rooms!
	var possible_room_locations = get_open_adjacent_rooms(rooms_data, [0,0])
	var generated_rooms = []
	for _i in range(room_count):
		var rand_room_type = (randi() % (NUM_ROOM_TYPES - 2)) + 2 # cannot be start or end rooms
		var rand_room_loc = select_rand_room_location(possible_room_locations, rooms_data)
		rooms_data[str(rand_room_loc)] = {"type":rand_room_type, "coords":rand_room_loc}
		generated_rooms.append(rand_room_loc)
		possible_room_locations += get_open_adjacent_rooms(rooms_data, rand_room_loc)
	
	# make one the exit
	var exit_loc = select_rand_room_location(possible_room_locations, rooms_data)
	rooms_data[str(exit_loc)] = {"type": EXIT_ROOM_TYPE_IND, "coords":exit_loc}
	
	return rooms_data

func get_open_adjacent_rooms(rooms_data: Dictionary, coords):
	var empty_adjacent_rooms = []
	var adj_coords = [
		[coords[0] + 0, coords[1] + 1], # U
		[coords[0] + 1, coords[1] + 0], # R
		[coords[0] + 0, coords[1] - 1], # D
		[coords[0] - 1, coords[1] + 0], # L
	]
	# check all adjacent spaces; if there's no room, it's an empty adjacent room
	for coord in adj_coords:
		if not str(coord) in rooms_data:
			empty_adjacent_rooms.append(coord)
	return empty_adjacent_rooms

func select_rand_room_location(possible_room_locations: Array, rooms_data: Dictionary):
	# pick a card, any card
	var rand_ind = randi() % possible_room_locations.size()
	var rand_room_loc = possible_room_locations[rand_ind]
	possible_room_locations.remove(rand_ind) # we picked it, so it goes away
	# double check if it's empty. if it's not, we pick again.
	if str(rand_room_loc) in rooms_data:
		rand_room_loc = select_rand_room_location(possible_room_locations, rooms_data)
	# otherwise, we're good to go!
	return rand_room_loc 

func generate_rooms(rooms_data_list : Dictionary) -> Dictionary:
	var spawn_locations = {
		"enemy_spawn_locations": [],
		"chest_spawn_locations": [],
		"party_spawn_locations": [],
		"exit_coords": [0, 0]
	}
	
	var walkable_floor_tiles = {}
	for room_data in rooms_data_list.values():
		# let's set up positional data!
		var coords = room_data.coords
		var x_pos = coords[0] * ROOMS_SIZE
		var y_pos = coords[1] * ROOMS_SIZE
		var type = room_data.type
		var x_pos_img = (type % ROOM_DATA_IMAGE_ROW_LEN) * ROOMS_SIZE
		var y_pos_img = (type / ROOM_DATA_IMAGE_ROW_LEN) * ROOMS_SIZE
		# travel through this room's pixel data TODO: allow for rotation of rooms
		for x in range(ROOMS_SIZE):
			for y in range(ROOMS_SIZE):
				rooms_texture_data.lock()
				var cell_data = rooms_texture_data.get_pixel(x_pos_img + x, y_pos_img + y)
				var cell_coords = [x_pos+x, y_pos+y]
				var wall_tile = false # assume we're not a wall
				match cell_data:
					COLOR_CODE.Wall:
						var wall_type = get_rand_wall_type()
						tilemap.set_cell(x_pos+x, y_pos+y, wall_type, randi()%2==0, randi()%2==0)
						wall_tile = true
					COLOR_CODE.Enemy:
						spawn_locations.enemy_spawn_locations.append(cell_coords)
					COLOR_CODE.Chest:
						spawn_locations.chest_spawn_locations.append(cell_coords)
					COLOR_CODE.Spawn:
						spawn_locations.party_spawn_locations.append(cell_coords)
					COLOR_CODE.Exit:
						spawn_locations.exit_coords = cell_coords
				if !wall_tile:
					walkable_floor_tiles[str([x_pos + x, y_pos + y])] = [x_pos + x, y_pos + y]
		
		# fill in walls for empty adjacent rooms
		var room_at_left = str([coords[0]-1, coords[1]]) in rooms_data_list
		var room_at_right = str([coords[0]+1, coords[1]]) in rooms_data_list
		var room_at_top = str([coords[0], coords[1]-1]) in rooms_data_list
		var room_at_bottom = str([coords[0], coords[1]+1]) in rooms_data_list
		if !room_at_left:
			fill_wall(x_pos, y_pos+3, walkable_floor_tiles)
			fill_wall(x_pos, y_pos+4, walkable_floor_tiles)
		if !room_at_right:
			fill_wall(x_pos+ROOMS_SIZE-1, y_pos+3, walkable_floor_tiles)
			fill_wall(x_pos+ROOMS_SIZE-1, y_pos+4, walkable_floor_tiles)
		if !room_at_top:
			fill_wall(x_pos+3, y_pos, walkable_floor_tiles)
			fill_wall(x_pos+4, y_pos, walkable_floor_tiles)
		if !room_at_bottom:
			fill_wall(x_pos+3, y_pos+ROOMS_SIZE-1, walkable_floor_tiles)
			fill_wall(x_pos+4, y_pos+ROOMS_SIZE-1, walkable_floor_tiles)
	init_astar(walkable_floor_tiles)
	return spawn_locations

func init_astar(walkables):
	astar_points_cache = {}
	for tile_coord in walkables.values():
		var tile_id = astar.get_available_point_id()
		astar.add_point(tile_id, Vector2(tile_coord[0], tile_coord[1]))
		astar_points_cache[str([tile_coord[0], tile_coord[1]])] = tile_id
	
	for tile_coord in walkables.values():
		var tile_id = astar_points_cache[str([tile_coord[0], tile_coord[1]])]
		var left_x_key = str([tile_coord[0]-1, tile_coord[1]])
		if left_x_key in astar_points_cache:
			astar.connect_points(astar_points_cache[left_x_key], tile_id)
		var up_y_key = str([tile_coord[0], tile_coord[1]-1])
		if up_y_key in astar_points_cache:
			astar.connect_points(astar_points_cache[up_y_key], tile_id)

func get_rand_wall_type():
	var wall_type = 0
	return wall_type # TODO: once we have more walls, fix this

func fill_wall(x_pos, y_pos, walkables):
	tilemap.set_cell(x_pos, y_pos, get_rand_wall_type(), randi()%2==0, randi()%2==0)
	var str_coords = str([x_pos, y_pos])
	if str_coords in walkables:
		walkables.erase(str_coords)

func generate_objects(spawn_locations: Dictionary):
	var enemy_spawnrate = 0.25
	var chest_spawnrate = 0.25
	spawn_objects_at_locations(enemy, enemies, spawn_locations.enemy_spawn_locations, enemy_spawnrate)
	spawn_objects_at_locations(chest, chests, spawn_locations.chest_spawn_locations, chest_spawnrate)
	
	# exit doesn't need to be spawned, just move it to the right spot.
	exit.global_position = map_to_world(spawn_locations.exit_coords)
	
	# spawn the party in
	for child in party.get_children():
		child.global_position = map_to_world(spawn_locations.party_spawn_locations[0])
		spawn_locations.party_spawn_locations.remove(0)

func spawn_objects_at_locations(object, list_node, location_list: Array, spawn_chance: float):
	for loc in location_list:
		if randf() < spawn_chance:
			var inst = object.instance()
			list_node.add_child(inst)
			inst.global_position = map_to_world(loc)

func map_to_world(coord):
# warning-ignore:integer_division
# warning-ignore:integer_division
	return tilemap.map_to_world(Vector2(coord[0], coord[1])) + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)

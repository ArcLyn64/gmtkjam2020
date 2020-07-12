extends StaticBody2D

func get_rand_from_arr(arr):
	return arr[randi() % arr.size()]

func change_color(color: Color):
	$Sprite.set_modulate(color)

func crack_chest(floor_level):
	# roll item
	var skill_name = get_rand_from_arr(SkillCompendium.compendium.keys())
	var skill_level = floor_level + (randi() % 5)
	var item = {
		"name": skill_name,
		"level": skill_level
	}
	$AudioStreamPlayer2D.play()
	queue_free()
	return item

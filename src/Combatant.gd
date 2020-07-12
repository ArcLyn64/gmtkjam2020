extends Node2D
class_name Combatant

const HP_BASE = 50
const HP_GAIN_RATE = 1.1
const HP_MAX = 999
const SP_BASE = 25
const SP_GAIN_RATE = 1.1
const SP_MAX = 999

const BASE_STAT = 1

const XP_BASE = 10
const XP_GAIN_RATE = 1.1
const XP_REWARD_PROP = 0.5

const AG_CHARGE = 10
const READY_CHARGE = 100.0

# personality traits
var empathy = 0.2 # how low is "critical hp"
var bloodlust = 0.2 # how low is "easy kill"
var fear = 0.1 # how low is "need help"
var tired = 0.4 # how low is "tired"

var charge = 0.0

var stats = {
	"at" : BASE_STAT,
	"ma" : BASE_STAT,
	"ag" : BASE_STAT,
	"en" : BASE_STAT
}

enum {
	ST,
	NE,
	WK
}
var res = {
	"phys" : NE,
	"fire" : NE,
	"dark" : NE,
	"wind" : NE
}

var buffs = {
	"at": 1,
	"ag": 1,
	"en": 1
}

var level: int = 1
var xp: int = 0

const actions = {
	"z" : "skill",
	"x" : "ask",
	"c" : "item",
	"v" : "flee",
}

var item = {
	"z" : "prev",
	"x" : "use",
	"c" : "next",
	"v" : "back"
}

var requests = {
	"z" : "defend",
	"x" : "heal",
	"c" : "run",
	"v" : "back",
}

var skills = {
	"z" : null,
	"x" : null,
	"c" : null,
	"v" : "back"
}

var items = []

var hp: int = max_hp()
var sp: int = max_sp()

var combatant_name: String = ""

var in_battle: bool = false

enum AI{
	player,
	ally,
	enemy
}
var ai = AI.player

var request = null

func charge_up(delta):
	var add = delta * stats["ag"] * AG_CHARGE
	charge = min(charge + add, READY_CHARGE)

func charged():
	return charge >= READY_CHARGE

func release():
	charge = 0

func set_ai(ai_type: String):
	match ai_type:
		"player":
			ai = AI.player
		"ally":
			ai = AI.ally
		"enemy":
			ai = AI.enemy

# AI only
func act(allyarr, enemyarr):
	if !charged():
		return
	match ai:
		AI.player:
			pass # player does not need an AI
		AI.ally:
			if request != null:
				match request["type"]:
					"heal":
						var hskillbind = get_hskill_bind()
						var hitem = get_heal_item()
						if hskillbind != null and can_cast(hskillbind):
							return cast_skill(hskillbind, request["from"])
						elif hitem != null:
							return use_item(hitem, request["from"])
						else:
							request = null
							return act(allyarr, enemyarr)
					"defend":
						release()
						return combatant_name + " bides their time."
					"run":
						for ally in allyarr:
							ally.request = {
								"type": "run",
								"from": self
							}
						return leave_battle()
				request = null
			else:
				var low_ally = find_lowest(allyarr)
				var low_enemy = find_lowest(enemyarr)
				if (float(low_ally.hp / low_ally.max_hp()) < empathy):
					# heal them
					var hskillbind = get_hskill_bind()
					var hitem = get_heal_item()
					if hskillbind != null and can_cast(hskillbind):
						return cast_skill(hskillbind, low_ally)
					elif hitem != null:
						return use_item(hitem, low_ally)
				if (float(low_enemy.hp / low_enemy.max_hp()) < bloodlust):
					var dbind = get_damage_bind()
					var ditem = get_damage_item()
					if dbind != null and can_cast(dbind):
						return cast_skill(dbind, low_enemy)
					elif ditem != null:
						return use_item(ditem, low_enemy)
					# punch them
				# cast random skill
				var skill_num = randi() % 3
				var bind = ["z", "x", "c"][skill_num]
				if skills[bind] != null and can_cast(bind):
					var skill_name = skills[bind]["name"]
					var skillinfo = SkillCompendium.compendium[skill_name]
					if skillinfo["target"] == SkillCompendium.TARGET.ALLY:
						return cast_skill(bind, low_ally)
					else:
						return cast_skill(bind, low_enemy)
		AI.enemy:
			var skill_num = randi() % 3
			var bind = ["z", "x", "c"][skill_num]
			if skills[bind] != null and can_cast(bind):
				var skill_name = skills[bind]["name"]
				var skillinfo = SkillCompendium.compendium[skill_name]
				if skillinfo["target"] == SkillCompendium.TARGET.ALLY:
					var target_ind = randi() % (enemyarr.size())
					return cast_skill(bind, enemyarr[target_ind])
				else:
					var target_ind = randi() % (allyarr.size())
					return cast_skill(bind, allyarr[target_ind])

func roll_skills():
	var skill_names = SkillCompendium.compendium.keys()
	for bind in ["z", "x", "c"]:
		var skill_name = skill_names[randi() % skill_names.size()]
		assign_skill(bind, skill_name, 1)

func find_lowest(arr):
	var lowest = arr[0]
	for unit in arr:
		if unit.hp < lowest.hp:
			lowest = unit
	return lowest

func get_hskill_bind():
	for bind in ["z", "x", "c"]:
		if skills[bind]["name"] == "heal":
			return bind
	return null

func get_damage_bind():
	for bind in ["z", "x", "c"]:
		if skills[bind]["name"] in ["strike", "fire", "dark", "wind"]:
			return bind
	return null

func get_damage_item():
	for i in range(items.size()):
		if items[i]["name"] in ["strike", "fire", "dark", "wind"]:
			return i
	return null

func get_heal_item():
	for i in range(items.size()):
		if items[i]["name"] == "heal":
			return i
	return null

func leave_battle():
	buffs["at"] = 1
	buffs["ag"] = 1
	buffs["en"] = 1
	in_battle = false
	release()
	return combatant_name + " flees..."

func enter_battle():
	in_battle = true

func init(n: String):
	combatant_name = n
	roll_skills()

func pickup_item(skill_name, skill_level):
	items.append({
		"name": skill_name,
		"level": skill_level
	})

func dead() -> bool:
	return hp <= 0

func xp_reward() -> int:
	return int(next_xp() * XP_REWARD_PROP)

func max_hp() -> int:
	return int(min(HP_BASE * pow(HP_GAIN_RATE, level), HP_MAX))

func max_sp() -> int:
	return int(min(SP_BASE * pow(SP_GAIN_RATE, level), SP_MAX))

func next_xp() -> int:
	return int(XP_BASE * pow(XP_GAIN_RATE, level))

func assign_skill(bind, skill_name, skill_level):
	assert(bind in skills and bind != "v")
	skills[bind] = {
		"name": skill_name,
		"level": skill_level
	}

func check_level_up() -> bool:
	if xp >= next_xp():
		xp = xp - next_xp()
		level += 1
		return true
	return false

func get_stats() -> Dictionary:
	return {
		"at" : stats["at"] * buffs["at"],
		"ma" : stats["ma"] * buffs["at"],
		"ag" : stats["ag"] * buffs["ag"],
		"en" : stats["en"] * buffs["en"]
	}

func cast_skill(bind, target: Combatant):
	var skill_name = skills[bind]["name"]
	var skill_level = skills[bind]["level"]
	var cost = SkillCompendium.get_cost(max_hp(), skill_name, skill_level)
	var damage = SkillCompendium.get_damage(get_stats(), target.get_stats(), skill_name, skill_level)
	var buf = SkillCompendium.get_buff(get_stats(), skill_name, skill_level)
	var heal = SkillCompendium.get_heal(get_stats(), skill_name, skill_level)
	
	var final_damage = 0
	
	# pay cost
	assert(can_cast(bind))
	hp -= cost["hp"]
	sp -= cost["sp"]
	
	# calculate damage dealt
	for type in damage:
		match res[type]:
			ST:
				pass # no damage taken
			NE:
				target.hp -= damage[type]
				final_damage += damage[type]
			WK:
				target.hp -= target.hp # instakill weaks
				final_damage += target.hp
	
	# calculate buffs
	for type in buf:
		buffs[type] *= buf[type]
	
	# calculate heals
	target.hp = min(target.hp + heal["heal"], target.max_hp())
	release()
	if heal["heal"] > 0:
		return combatant_name + " heals " + target.combatant_name + " for " + heal["heal"] + "."
	return combatant_name + " hits " + target.combatant_name + " with " + skill_title(bind) + " for " + str(final_damage) + "!"

func can_cast(bind):
	var cost = skill_cost(bind)
	return cost["hp"] < hp and cost["sp"] <= sp

func use_item(ind, target: Combatant):
	var skill_name = items[ind]["name"]
	var skill_level = items[ind]["level"]
	var damage = SkillCompendium.get_damage(get_stats(), target.get_stats(), skill_name, skill_level)
	var buf = SkillCompendium.get_buff(get_stats(), skill_name, skill_level)
	var heal = SkillCompendium.get_heal(get_stats(), skill_name, skill_level)
	
	# spend item
	items.remove(ind)
	
	var final_damage = 0
	
	# calculate damage dealt
	for type in damage:
		match res[type]:
			ST:
				pass # no damage taken
			NE:
				target.hp -= damage[type]
				final_damage += damage[type]
			WK:
				target.hp -= target.hp # instakill weaks
				final_damage += target.hp
	
	# calculate buffs
	for type in buf:
		buffs[type] *= buf[type]
	
	# calculate heals
	target.hp = min(target.hp + heal["heal"], target.max_hp())
	
	release()
	if heal["heal"] > 0:
		return combatant_name + " heals " + target.combatant_name + " for " + heal["heal"] + "."
	return combatant_name + " hits " + target.combatant_name + " with " + item_title(ind) + " for " + str(final_damage) + "!"

func cast_resurrect(target: Combatant):
	var resurrect_cost = max_sp() / 2
	assert(sp >= resurrect_cost)
	assert(target.hp < 1)
	sp -= resurrect_cost
	target.hp = target.max_hp() / 2
	release()

func skill_title(bind):
	var skill_name = skills[bind]["name"]
	var skill_level = skills[bind]["level"]
	return str(skill_name) + " " + str(skill_level)

func skill_cost(bind):
	return SkillCompendium.get_cost(max_hp(), skills[bind]["name"], skills[bind]["level"])

func skill_display_info(bind) -> Dictionary:
	return {
		"name" : skill_title(bind),
		"cost" : skill_cost(bind)
	}

func item_title(ind):
	var skill_name = items[ind]["name"]
	var skill_level = items[ind]["level"]
	return str(skill_name) + " " + str(skill_level) + " orb"

func make_request(bind, target: Combatant):
	target.request = {
		"type": requests[bind],
		"from": self
	}
	release()
	return combatant_name + " asks " + target.combatant_name + " to " + requests[bind] + "."

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

func leave_battle():
	buffs["at"] = 1
	buffs["ag"] = 1
	buffs["en"] = 1
	in_battle = false

func enter_battle():
	in_battle = true

func init(n: String):
	combatant_name = n

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
	
	# pay cost
	assert(cost["hp"] < hp and cost["sp"] <= sp)
	hp -= cost["hp"]
	sp -= cost["sp"]
	
	# calculate damage dealt
	for type in damage:
		match res[type]:
			ST:
				pass # no damage taken
			NE:
				target.hp -= damage[type]
			WK:
				target.hp -= target.hp # instakill weaks
	
	# calculate buffs
	for type in buf:
		buffs[type] *= buf[type]
	
	# calculate heals
	target.hp = min(target.hp + heal["heal"], target.max_hp())

func use_item(ind, target: Combatant):
	var skill_name = items[ind]["name"]
	var skill_level = items[ind]["level"]
	var damage = SkillCompendium.get_damage(get_stats(), target.get_stats(), skill_name, skill_level)
	var buf = SkillCompendium.get_buff(get_stats(), skill_name, skill_level)
	var heal = SkillCompendium.get_heal(get_stats(), skill_name, skill_level)
	
	# spend item
	items.remove(ind)
	
	# calculate damage dealt
	for type in damage:
		match res[type]:
			ST:
				pass # no damage taken
			NE:
				target.hp -= damage[type]
			WK:
				target.hp -= target.hp # instakill weaks
	
	# calculate buffs
	for type in buf:
		buffs[type] *= buf[type]
	
	# calculate heals
	target.hp = min(target.hp + heal["heal"], target.max_hp())

func cast_resurrect(target: Combatant):
	var resurrect_cost = max_sp() / 2
	assert(sp >= resurrect_cost)
	assert(target.hp < 1)
	sp -= resurrect_cost
	target.hp = target.max_hp() / 2

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

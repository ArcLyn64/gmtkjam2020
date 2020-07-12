extends Node2D
class_name SkillCompendium

# phys skill data
const AT_DAM_BASE = 25
const AT_DAM_GROWTH = 1.1
const AT_DAM_MAX = 999
const AT_COST_BASE = 5 # percentage of hp
const AT_COST_GROWTH = 1.1
# magi skill data
const MA_DAM_BASE = 25
const MA_DAM_GROWTH = 1.1
const MA_DAM_MAX = 999
const MA_COST_BASE = 3
const MA_COST_GROWTH = 1.1
# buff/debuff skill data
const BU_INC_BASE = 1.2 # rate of increase
const BU_INC_GROWTH = 1.1
const BU_INC_MAX = 10 # rate of increase
const BU_COST_BASE =  8
const BU_COST_GROWTH = 1.1
# heal skill data
const HE_AMT_BASE = 40
const HE_AMT_GROWTH = 1.1
const HE_AMT_MAX = 999
const HE_COST_BASE = 3
const HE_COST_GROWTH = 1.1

const HP_COST_MAX = 75
const SP_COST_MAX = 500

const AT_SCALING_FACTOR = 1.05
const AT_SCALING_BASE = 1

const BUF_SCALING_FACTOR = 1.05
const BUF_SCALING_BASE = 1

const HE_SCALING_FACTOR = 1.05
const HE_SCALING_BASE = 1

const EN_REDUCTION_FACTOR = 1.05
const EN_REDUCTION_BASE = 1


enum TARGET{
	ALLY,
	FOE
}

const compendium = {
	"strike": {
		"target": TARGET.FOE,
		"scale": {
			"at" : true,
			"ma" : false,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : true,
			"fire" : false,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": true,
			"sp": false
		},
		"heal": false
	},
	"fire": {
		"target": TARGET.FOE,
		"scale": {
			"at" : false,
			"ma" : true,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : true,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"dark": {
		"target": TARGET.FOE,
		"scale": {
			"at" : false,
			"ma" : true,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : true,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"wind": {
		"target": TARGET.FOE,
		"scale": {
			"at" : false,
			"ma" : true,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : false,
			"wind" : true
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"focus": {
		"target": TARGET.ALLY,
		"scale": {
			"at" : false,
			"ma" : false,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": true,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"rush": {
				"target": TARGET.ALLY,
		"scale": {
			"at" : false,
			"ma" : false,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": true,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"guard": {
				"target": TARGET.ALLY,
		"scale": {
			"at" : false,
			"ma" : false,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": true
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"disarm": {
		"target": TARGET.FOE,
		"scale": {
			"at" : false,
			"ma" : false,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": true,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"trip": {
		"target": TARGET.FOE,
		"scale": {
			"at" : false,
			"ma" : false,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": true,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"break": {
		"target": TARGET.FOE,
		"scale": {
			"at" : false,
			"ma" : false,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": true
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": false
	},
	"heal": {
		"target": TARGET.ALLY,
		"scale": {
			"at" : false,
			"ma" : false,
			"ag" : false,
			"en" : false
		},
		"dam": {
			"phys" : false,
			"fire" : false,
			"dark" : false,
			"wind" : false
		},
		"buf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"dbuf": {
			"at": false,
			"ag": false,
			"en": false
		},
		"cost": {
			"hp": false,
			"sp": true
		},
		"heal": true
	},
}

const at_skills = [
	"strike"
]

const ma_skills = [
	"fire",
	"dark",
	"wind"
]

const ag_skills = [
	"focus",
	"rush",
	"guard",
	"disarm",
	"trip",
	"break",
]

const en_skills = [
	"heal"
]

static func get_damage(stats, target_stats, skill_name, skill_level) -> Dictionary:
	var skillinfo = compendium[skill_name]
	var damage = {}
	for type in skillinfo["dam"]:
		if !skillinfo["dam"][type]:
			damage[type] = 0
		else :
			var scaling = 0
			for stat in stats:
				if skillinfo["scale"][stat]:
					scaling += AT_SCALING_BASE* pow(AT_SCALING_FACTOR, stats[stat])
			if type == "phys":
				damage[type] = min((AT_DAM_BASE * pow(AT_DAM_GROWTH, skill_level)) + scaling, AT_DAM_MAX)
				var reduction = max(target_stats["en"] - stats["at"], 0)
				damage[type] = damage[type] / (EN_REDUCTION_BASE * pow(EN_REDUCTION_FACTOR, reduction))
			else:
				damage[type] = min((MA_DAM_BASE * pow(MA_DAM_GROWTH, skill_level)) + scaling, MA_DAM_MAX)
				var reduction = max(target_stats["en"] - stats["ma"], 0)
				damage[type] = damage[type] / (EN_REDUCTION_BASE * pow(EN_REDUCTION_FACTOR, reduction))
			damage[type] = int(damage[type])
	return damage

static func get_buff(stats, skill_name, skill_level) -> Dictionary:
	var skillinfo = compendium[skill_name]
	var buf = {}
	for type in skillinfo["buf"]:
		if !skillinfo["buf"][type]:
			buf[type] = 1
		else:
			var scaling = 1
			for stat in stats:
				if skillinfo["scale"][stat]:
					scaling *= BUF_SCALING_BASE * pow(BUF_SCALING_FACTOR, stats[stat])
			buf[type] = min((BU_INC_BASE * pow(BU_INC_GROWTH, skill_level)) * scaling, BU_INC_MAX)
	for type in skillinfo["dbuf"]:
		if !skillinfo["dbuf"][type]:
			buf[type] = 1
		else:
			var scaling = 1
			for stat in stats:
				if skillinfo["scale"][stat]:
					scaling *= BUF_SCALING_BASE * pow(BUF_SCALING_FACTOR, stats[stat])
			buf[type] = 1 / min((BU_INC_BASE * pow(BU_INC_GROWTH, skill_level)) * scaling, BU_INC_MAX)
	return buf

static func get_heal(stats, skill_name, skill_level) -> Dictionary:
	var skillinfo = compendium[skill_name]
	var heal = {}
	if !skillinfo["heal"]:
		heal["heal"] = 0
	else:
		var scaling = 0
		for stat in stats:
			if skillinfo["scale"][stat]:
				scaling += HE_SCALING_BASE* pow(HE_SCALING_FACTOR, stats[stat])
		heal["heal"] = int(min((HE_AMT_BASE * pow(HE_AMT_GROWTH, skill_level)) + scaling, HE_AMT_MAX))
	return heal

static func get_cost(max_hp, skill_name, skill_level) -> Dictionary:
	var skillinfo = compendium[skill_name]
	var cost = {
		"hp": 0,
		"sp": 0
	}
	
	# dam cost
	for type in skillinfo["dam"]:
		if skillinfo["dam"][type]:
			if type == "phys":
				cost["hp"] += AT_COST_BASE * pow(AT_COST_GROWTH, skill_level)
			else:
				cost["sp"] += MA_COST_BASE * pow(MA_COST_GROWTH, skill_level)
	
	# buf cost
	for type in skillinfo["buf"]:
		if skillinfo["buf"][type]:
			cost["sp"] += BU_COST_BASE * pow(BU_COST_GROWTH, skill_level)
	for type in skillinfo["dbuf"]:
		if skillinfo["dbuf"][type]:
			cost["sp"] += BU_COST_BASE * pow(BU_COST_GROWTH, skill_level)
	
	# heal cost
	if skillinfo["heal"]:
		cost["sp"] += HE_COST_BASE * pow(HE_COST_GROWTH, skill_level)
	
	cost["hp"] = int(min(cost["hp"], HP_COST_MAX) / 100 * max_hp)
	cost["sp"] = int(min(cost["sp"], SP_COST_MAX))
	
	return cost

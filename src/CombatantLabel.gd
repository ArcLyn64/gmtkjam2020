extends PanelContainer
class_name CombatantLabel

onready var hpbar: ColorRect = $VBoxContainer/HP/HPBar
onready var hp_lbl: Label = $VBoxContainer/HP
onready var spbar: ColorRect = $VBoxContainer/SP/SPBar
onready var sp_lbl: Label = $VBoxContainer/SP
onready var name_lbl: Label = $VBoxContainer/Name
onready var indicator: ColorRect = $IndicatorControl/Indicator

const SELECTED_COLOR = Color.gray
const IDLE_COLOR = Color(0,0,0,0)

const BAR_H = 5
const MAX_BAR_W = 50.0
const BAR_X = 5

var selected: bool = false

var combatant : Combatant = null

func select():
	selected = true

func deselect():
	selected = false

func init(cbt):
	combatant = cbt.get_combatant_data()

func _ready():
	format_display()

func _process(delta):
	indicator.rect_size = Vector2(BAR_X, rect_size[1])
	if selected:
		indicator.show()
	else:
		indicator.hide()
	format_display()

func format_display():
	if combatant == null:
		return
	var pct_hp = float(combatant.hp) / combatant.max_hp()
	var pct_sp = float(combatant.sp) / combatant.max_sp()
	hpbar.rect_size = Vector2(MAX_BAR_W * pct_hp, BAR_H)
	spbar.rect_size = Vector2(MAX_BAR_W * pct_sp, BAR_H)
	hp_lbl.text = str(combatant.hp)
	sp_lbl.text = str(combatant.sp)
	name_lbl.text = combatant.combatant_name

func test_init(what: String):
	combatant = Combatant.new()
	combatant.level = 10
	combatant.hp = combatant.max_hp()
	combatant.sp = combatant.max_sp()
	combatant.assign_skill("z", "strike", 1)
	combatant.assign_skill("x", "fire", 1)
	combatant.assign_skill("c", "heal", 1)
	combatant.pickup_item("rush", 1)
	combatant.pickup_item("break", 1)
	combatant.pickup_item("strike", 2)
	combatant.init(what)

func leave_battle():
	combatant.leave_battle()
	queue_free()

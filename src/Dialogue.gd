extends Control

onready var dialogue_player = $DialoguePlayer
onready var name_lbl = $Name
onready var text_lbl = $Text

var scroll_speed = 0.2
var wait_time = 2
var start_time = 1
var timer = 0

var cur_dialogue = []

enum STATE{
	starting,
	writing,
	waiting,
	hidden
}
var cur_state = STATE.hidden

func read_json(json_fp) -> Dictionary:
	var file = File.new()
	assert(file.file_exists(json_fp))
	
	file.open(json_fp, file.READ)
	var dialogue = parse_json(file.get_as_text())
	assert(dialogue.size() > 0)
	return dialogue

func start(json_fp):
	cur_dialogue = read_json(json_fp).values()
	begin_playback()

func begin_playback():
	name_lbl.text = ""
	text_lbl.text = ""
	timer = 0
	cur_state = STATE.starting

func _process(delta):
	match cur_state:
		STATE.hidden:
			self.hide()
		STATE.starting:
			self.show()
			if timer > start_time:
				timer = 0
				$MessageNoise.play()
				cur_state = STATE.writing
			else:
				timer += delta
		STATE.waiting:
			if timer > wait_time:
				timer = 0
				text_lbl.visible_characters = 0
				cur_dialogue.remove(0)
				if cur_dialogue.size() > 0:
					$MessageNoise.play()
					cur_state = STATE.writing
				else:
					cur_state = STATE.hidden
			else:
				timer += delta
		STATE.writing:
			name_lbl.text = cur_dialogue[0].name
			text_lbl.text = cur_dialogue[0].text
			
			if timer > scroll_speed:
				if text_lbl.visible_characters >= text_lbl.text.length():
					timer = 0
					cur_state = STATE.waiting
				else:
					text_lbl.visible_characters += 1
			else:
				timer += delta

extends Control
var dialog_json
var next
var options
var choice
var script_path
var option_1
var option_2
const option_timer = 10.0
var timer_started = false
var test = 0
@onready var dialogue_label: RichTextLabel = $Panel/RichTextLabel
var text_animating = true
var text_speed = 0.01
func _ready() -> void:
	process_dialog()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer_started and $Panel/player_choice.visible:
		%ProgressBar.value = snapped(%OptionTimer.time_left,0.01) * 10
	if Input.is_action_just_pressed("interact") and not $Panel/player_choice.visible and text_animating == false:
		process_dialog()
		text_animating = true
	elif Input.is_action_just_pressed("interact") and not $Panel/player_choice.visible and text_animating == true:
		$Panel/RichTextLabel.skip()
		text_animating = false

			
			
func parse_json(text):
	return JSON.parse_string(text)

func read_json_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content_as_text = file.get_as_text()
	var content_as_dictionary = parse_json(content_as_text)
	return content_as_dictionary

func process_dialog():
	if not dialog_json:
		#initializing dialog object if this is intial instantiation of dialog
		dialog_json = read_json_file("res://dialog/{map}.json".format({"map": Global.current_scene}))
		#$Panel/RichTextLabel.text = dialog_json["Text"]
		$Panel/Label.text = dialog_json["Char"] + ":"
		# Load and assign a new texture
		$Panel/TextureRect.texture = load("res://asset/characters/{char}.png".format({"char": dialog_json["Char"]}))
		if text_animating:
			text_animating = await dialogue_label.show_dialogue(dialog_json["Text"], text_speed)
		else:
			$Panel/RichTextLabel.text = dialog_json["Text"]
		next = dialog_json["Next"]
		options = dialog_json["Options"]
		
	elif options == false and next:
		#This is for dialog options that doesn't have a choice
		script_path = dialog_json[next[0]]
		$Panel/Label.text = script_path["Char"] + ":"
		$Panel/TextureRect.texture = load("res://asset/characters/{char}.png".format({"char": script_path["Char"]}))
		text_animating = await dialogue_label.show_dialogue(script_path["Text"], text_speed)
		options = script_path["Options"]
		next = script_path["Next"]
		if next:
			script_path = dialog_json[next[0]]
	elif next:
		option_1 = dialog_json[next[0]]
		option_2 = dialog_json[next[1]]
		$Panel/player_choice.visible = true
		$Panel/player_choice/option1.text = option_1["Text"]
		$Panel/player_choice/option2.text = option_2["Text"]
		#if script_path["Options"]:
			#$Panel/player_choice.visible = true
		#else:
			#$Panel/player_choice.visible = false
		if $Panel/player_choice.visible:
			%ProgressBar.max_value = option_timer * 10
			%OptionTimer.wait_time = option_timer
			%OptionTimer.start()
			timer_started = true
		#script_path = dialog_json[next[0]]
		$Panel/Label.text = script_path["Char"] + ":"
		$Panel/TextureRect.texture = load("res://asset/characters/{char}.png".format({"char": script_path["Char"]}))
		$Panel/RichTextLabel.text = ""
		#if next:
		## depending on player selection it can go to next 0 or 1 for now it is set to just 1 I will have to modify this later
			#dialog_json = dialog_json[next[choice]]
	else:
		Global.current_scene = dialog_json["Next_Scene"]
		self.queue_free()
		SceneTransition.change_scene("res://{scene}.tscn".format({"scene": dialog_json["Next_Scene"]}))




func _on_option_1_button_down() -> void:
	choice = 0
	$Panel/player_choice.visible = false
	script_path = dialog_json[option_1["Next"][0]]
	options = option_1["Options"]
	next = option_1["Next"]
	process_dialog()


func _on_option_2_button_down() -> void:
	choice = 1
	$Panel/player_choice.visible = false
	script_path = dialog_json[option_2["Next"][0]]
	options = option_2["Options"]
	next = option_2["Next"]
	process_dialog()


func _on_option_timer_timeout() -> void:
	%OptionTimer.stop()
	choice = 0
	$Panel/player_choice.visible = false
	timer_started = false
	script_path = dialog_json[option_1["Next"][0]]
	options = option_1["Options"]
	next = option_1["Next"]
	process_dialog()

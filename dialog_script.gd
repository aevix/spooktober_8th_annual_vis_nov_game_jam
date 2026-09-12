extends Control
var dialog_json
var next
var choice
const option_timer = 10.0
var timer_started = false

func _ready() -> void:
	process_dialog()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer_started and $CanvasLayer/Panel/player_choice.visible:
		%ProgressBar.value = snapped(%OptionTimer.time_left,0.01) * 10
	if Input.is_action_just_pressed("interact") and not $CanvasLayer/Panel/player_choice.visible:
		process_dialog()
			
func parse_json(text):
	return JSON.parse_string(text)

func read_json_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content_as_text = file.get_as_text()
	var content_as_dictionary = parse_json(content_as_text)
	return content_as_dictionary

func process_dialog():
	if not dialog_json:
		dialog_json = read_json_file("res://dialog/{map}.json".format({"map": Global.current_scene}))
		$CanvasLayer/Panel/RichTextLabel.text = dialog_json["Text"]
		$CanvasLayer/Panel/Label.text = dialog_json["Char"] + ":"
		next = dialog_json["Next"]
	elif next:
		dialog_json = dialog_json[next[choice]]
		$CanvasLayer/Panel/RichTextLabel.text = dialog_json["Text"]
		$CanvasLayer/Panel/Label.text = dialog_json["Char"] + ":"
		next = dialog_json["Next"]
		if next:
		# depending on player selection it can go to next 0 or 1 for now it is set to just 1 I will have to modify this later
			dialog_json = dialog_json[next[choice]]
	else:
		self.queue_free()
	if dialog_json["Options"]:
		$CanvasLayer/Panel/player_choice.visible = true
	else:
		$CanvasLayer/Panel/player_choice.visible = false
	if $CanvasLayer/Panel/player_choice.visible:
		%ProgressBar.max_value = option_timer * 10
		%OptionTimer.wait_time = option_timer
		%OptionTimer.start()
		timer_started = true



func _on_option_1_button_down() -> void:
	choice = 0
	$CanvasLayer/Panel/player_choice.visible = false
	process_dialog()


func _on_option_2_button_down() -> void:
	choice = 1
	$CanvasLayer/Panel/player_choice.visible = false
	process_dialog()


func _on_option_timer_timeout() -> void:
	%OptionTimer.stop()
	choice = 1
	$CanvasLayer/Panel/player_choice.visible = false
	timer_started = false
	process_dialog()

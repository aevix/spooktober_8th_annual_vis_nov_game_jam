extends Control
var dialog_json
var next
var options
var choice
var script_path
var option_1
var option_2
const option_timer = 20
var timer_started = false
var test = 0
@onready var dialogue_label: RichTextLabel = $Panel/RichTextLabel
var text_animating = true
var text_speed = 0.01
var sfx

func _ready() -> void:
	process_dialog()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer_started and $Panel/player_choice.visible:
		%ProgressBar.value = snapped(%OptionTimer.time_left,0.01) * 10
	if Input.is_action_just_pressed("interact") and not $Panel/player_choice.visible and text_animating == false and not Global.mouse_entered:
		process_dialog()
		text_animating = true
	elif Input.is_action_just_pressed("interact") and not $Panel/player_choice.visible and text_animating == true and not Global.mouse_entered:
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
		if next[0] != "check_point":
			$Panel/Label.text = script_path["Char"] + ":"
			$Panel/TextureRect.texture = load("res://asset/characters/{char}.png".format({"char": script_path["Char"]}))
			text_animating = await dialogue_label.show_dialogue(script_path["Text"], text_speed)
		options = script_path["Options"]
		next = script_path["Next"]
		if next:
			script_path = dialog_json[next[0]]
			if Global.current_scene == "act_1" and next[0] == "cont_8":
				await BackgroundMusic.play_fade_out()
				BackgroundMusic.play_fade_in(preload("res://asset/big_assets/audio/act_1.ogg"))
	elif next:
		sfx = AudioStreamPlayer2D.new()
		add_child(sfx)
		var stream = preload("res://asset/big_assets/audio/sound effect/clock_ticking.ogg") as AudioStreamOggVorbis
		stream.loop = true
		sfx.stream = stream
		sfx.play()
		option_1 = dialog_json[next[0]]
		option_2 = dialog_json[next[1]]
		$Panel/player_choice.visible = true
		$Panel/player_choice/option1.text = option_1["Text"]
		fit_text_to_button($Panel/player_choice/option1)
		$Panel/player_choice/option2.text = option_2["Text"]
		fit_text_to_button($Panel/player_choice/option2)
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
		if Global.current_scene == "act_2":
			await BackgroundMusic.play_fade_out()
			await BackgroundMusic.play_fade_in(preload("res://asset/big_assets/audio/act_2.ogg"))
			
		elif Global.current_scene == "act_3":
			await BackgroundMusic.play_fade_out()
			await BackgroundMusic.play_fade_in(preload("res://asset/big_assets/audio/act_3.ogg"))

		elif Global.current_scene == "act_4":
			await BackgroundMusic.play_fade_out()
			await BackgroundMusic.play_fade_in(preload("res://asset/big_assets/audio/act_4.ogg"))
		await SceneTransition.change_scene("res://{scene}.tscn".format({"scene": dialog_json["Next_Scene"]}))
		self.queue_free()
	if len(next) and next[0] == "check_point":
		if Global.evil_score > 0:
			Global.current_scene = "act_4a"
			await BackgroundMusic.play_fade_out()
			await BackgroundMusic.play_fade_in(preload("res://asset/big_assets/audio/(Ambience) Final Day.ogg"))
			await SceneTransition.change_scene("res://act_4a.tscn")
			self.queue_free()
		else:
			script_path = dialog_json[next[0]]
			options = script_path["Options"]
			next = script_path["Next"]
			if next:
				script_path = dialog_json[next[0]]
		




func _on_option_1_button_down() -> void:
	%OptionTimer.stop()
	choice = 0
	$Panel/player_choice.visible = false
	script_path = dialog_json[option_1["Next"][0]]
	options = option_1["Options"]
	next = option_1["Next"]
	sfx.stop()
	sfx.queue_free()   
	process_dialog()


func _on_option_2_button_down() -> void:
	Global.evil_score += 1
	%OptionTimer.stop()
	choice = 1
	$Panel/player_choice.visible = false
	script_path = dialog_json[option_2["Next"][0]]
	options = option_2["Options"]
	next = option_2["Next"]
	sfx.stop()
	sfx.queue_free()  
	process_dialog()


func _on_option_timer_timeout() -> void:
	%OptionTimer.stop()
	choice = 0
	$Panel/player_choice.visible = false
	timer_started = false
	script_path = dialog_json[option_1["Next"][0]]
	options = option_1["Options"]
	next = option_1["Next"]
	sfx.stop()
	sfx.queue_free()  
	process_dialog()


func fit_text_to_button(btn: Button, max_font_size: int = 20, min_font_size: int = 8):
	btn.modulate.a = 0.0
	var font := btn.get_theme_font("font")
	var size := max_font_size
	while size > min_font_size:
		btn.add_theme_font_size_override("font_size", size)
		btn.queue_redraw()
		await get_tree().process_frame
		if btn.get_combined_minimum_size().y <= btn.size.y:
			break
		size -= 1
	btn.modulate.a = 1.0
 

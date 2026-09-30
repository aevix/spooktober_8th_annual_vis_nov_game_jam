extends Control
var fade_out_timer = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.evil_score > 0:
		$title.text = "Beauty is a Beast"
		$score.visible = false
		$score.text = "Evil Level: " + str(Global.evil_score)
	BackgroundMusic.play_fade_out()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	Global.current_scene = "introduction"
	SceneTransition.change_scene("res://introduction.tscn", fade_out_timer)
	Global.evil_score = 0
	fade_out_music($intro_music, fade_out_timer)
	$door_unlock.play()
	
	


func _on_exit_pressed() -> void:
	get_tree().quit()

func fade_out_music(audio_player: Node, duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -80.0, duration)
	tween.tween_callback(audio_player.stop)  # ← method reference, not (obj, "method")   

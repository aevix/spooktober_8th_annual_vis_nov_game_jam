extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func play_fade_in(track: AudioStream, duration: float = 1.5) -> void:
	player.stream = track
	player.volume_db = -80.0  # silent
	player.play()

	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0.0, duration)   

func play_fade_out(duration: float = 1.5) -> void:
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)
	await tween.finished
	player.stop()   

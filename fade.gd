extends CanvasLayer

@onready var fade: ColorRect = $Fade
# Go to Project → Project Settings → Globals → Autoload, browse to your scene file, set the node name to SceneTransition, and click Add.  Make sure the Enable checkbox is checked. 
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	fade.modulate.a = 0.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene(path: String, duration: float = 0.3) -> void:
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, duration)
	await tween.finished
	
	get_tree().change_scene_to_file(path)
	
	tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, duration)
	await tween.finished
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE   

extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dialog = preload("res://DialogSystem.tscn").instantiate()
	dialog.global_position = Vector2(0,0)
	add_child(dialog)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

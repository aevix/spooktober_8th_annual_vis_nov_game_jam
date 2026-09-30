extends HSlider

@export var bus_name: String = "Master"
var bus_index: int

func _ready():  
	# Get the index of the target audio bus
	bus_index = AudioServer.get_bus_index(bus_name)
	# Sync slider to current bus volume
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(value: float) -> void:
	# Convert linear slider value to decibels and set bus volume
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	# Optional: Mute if volume is near zero
	AudioServer.set_bus_mute(bus_index, value < 0.01)   


func _on_mouse_entered() -> void:
	Global.mouse_entered = true

func _on_mouse_exited() -> void:
	Global.mouse_entered = false

extends RichTextLabel

var tween: Tween

func show_dialogue(text: String, speed: float = 0.05):
	self.text = text
	self.visible_ratio = 0.0
	
	# Create a Tween to animate the visible_ratio
	tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, speed * text.length())
	await tween.finished
	return false
	# Note: speed is per-character, so multiply by length for total duration
	
func skip():
	if tween and tween.is_valid():
		tween.pause()
		tween.custom_step(9999.0)  # large delta jumps to the end
	self.visible_ratio = 1.0   

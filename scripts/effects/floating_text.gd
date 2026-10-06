class_name FloatingText
extends Node2D

## Floating arcade score and feedback text.
## Animates upward, scales, and fades out cleanly.

@onready var label: Label = $Label

func setup(text: String, color: Color = Color.WHITE) -> void:
	if label == null:
		label = get_node_or_null("Label")
	if label != null:
		label.text = text
		label.modulate = color
		
	# Tween animation: punch scale, rise up, and fade
	scale = Vector2(0.6, 0.6)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 45.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)

class_name Explosion
extends Node2D

## Handles arcade explosion VFX with frame animation, sparks, and camera shake.

@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var particles: CPUParticles2D = get_node_or_null("CPUParticles2D")

func _ready() -> void:
	if anim_sprite != null:
		anim_sprite.animation_finished.connect(_on_animation_finished)
		anim_sprite.play()
	if particles != null:
		particles.emitting = true
		
	# Trigger camera shake if camera exists
	var cams = get_tree().get_nodes_in_group("camera")
	if cams.size() > 0 and cams[0].has_method("shake"):
		cams[0].shake(0.2, 5.0)

func set_explosion_type(type: String) -> void:
	if anim_sprite != null and anim_sprite.sprite_frames.has_animation(type):
		anim_sprite.animation = type
		anim_sprite.play(type)
	if type == "large":
		scale = Vector2(1.5, 1.5)
		var cams = get_tree().get_nodes_in_group("camera")
		if cams.size() > 0 and cams[0].has_method("shake"):
			cams[0].shake(0.35, 10.0)

func _on_animation_finished() -> void:
	queue_free()

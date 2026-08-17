class_name Explosion
extends Node2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if anim_sprite != null:
		anim_sprite.animation_finished.connect(_on_animation_finished)
		anim_sprite.play()

func set_explosion_type(type: String) -> void:
	if anim_sprite != null and anim_sprite.sprite_frames.has_animation(type):
		anim_sprite.animation = type
		anim_sprite.play(type)

func _on_animation_finished() -> void:
	queue_free()

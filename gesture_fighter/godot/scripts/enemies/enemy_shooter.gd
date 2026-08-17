class_name EnemyShooter
extends Area2D

@export var speed: float = 250.0
@export var health: int = 30
@export var shoot_interval: float = 1.5

@onready var sprite: Sprite2D = $Sprite2D

var shoot_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_enemy_shooter_texture()
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x -= speed * delta
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		fire_enemy_bullet()
	
	if position.x < -100.0:
		queue_free()

func fire_enemy_bullet() -> void:
	var bullet = Area2D.new()
	bullet.collision_layer = 8 # EnemyProjectile layer
	bullet.collision_mask = 1 # Player layer
	
	var spr = Sprite2D.new()
	spr.texture = ProceduralAssets.create_powerup_texture(Color(1.0, 0.2, 0.2, 0.9))
	spr.scale = Vector2(0.5, 0.5)
	bullet.add_child(spr)
	
	var shape = CollisionShape2D.new()
	var cs = CircleShape2D.new()
	cs.radius = 8.0
	shape.shape = cs
	bullet.add_child(shape)
	
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	
	var b_script = GDScript.new()
	b_script.source_code = """
	extends Area2D
	var speed = 500.0
	func _ready():
		body_entered.connect(_on_body_entered)
	func _process(delta):
		position.x -= speed * delta
		if position.x < -100: queue_free()
	func _on_body_entered(body):
		if body.has_method('take_damage'):
			body.take_damage()
			queue_free()
	"""
	b_script.reload()
	bullet.set_script(b_script)

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("enemy_hit")
	if health <= 0:
		destroy()

func destroy() -> void:
	AudioManager.play_sound("enemy_destroy")
	GameManager.increment_destroyed()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage()
		destroy()

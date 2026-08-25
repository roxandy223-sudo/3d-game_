extends Node3D

const MAX_HEALTH := 150.0

var health := MAX_HEALTH
var dead := false
var hit_area: Area3D


func _ready() -> void:
	
	health = MAX_HEALTH
	
	create_hitbox()


func create_hitbox() -> void:
	
	hit_area = Area3D.new()
	hit_area.name = "BotHitbox"
	
	hit_area.collision_layer = 1
	hit_area.collision_mask = 1
	
	add_child(hit_area)
	
	
	var collision := CollisionShape3D.new()
	
	var shape := CapsuleShape3D.new()
	
	shape.radius = 0.45
	shape.height = 1.8
	
	collision.shape = shape
	
	hit_area.add_child(collision)
	
	
	# Make the hitbox point back to this bot.
	hit_area.set_meta(
		"bot",
		self
	)


func take_damage(amount: float) -> void:
	
	if dead:
		return
	
	health -= amount
	
	if health < 0.0:
		health = 0.0
	
	print(
		"BOT HIT | DAMAGE: ",
		amount,
		" | HP: ",
		health,
		"/",
		MAX_HEALTH
	)
	
	if health <= 0.0:
		die()


func is_dead() -> bool:
	
	return dead


func die() -> void:
	
	if dead:
		return
	
	dead = true
	
	print(
		name,
		" KILLED"
	)
	
	var tween := create_tween()
	
	tween.set_parallel(true)
	
	tween.tween_property(
		self,
		"rotation_degrees:z",
		90.0,
		0.2
	)
	
	tween.tween_property(
		self,
		"position:y",
		-0.5,
		0.2
	)
	
	await tween.finished
	
	queue_free()

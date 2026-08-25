extends Node3D

@export var bot_scene: PackedScene
@export var max_bots: int = 5
@export var spawn_radius: float = 15.0


func _ready() -> void:

	await get_tree().process_frame

	if bot_scene == null:
		push_error("Assign bot_scene in the Inspector!")
		return

	for i in range(max_bots):
		spawn_random_bot()


func spawn_random_bot() -> void:

	var bot_instance = bot_scene.instantiate()

	add_child(bot_instance)

	var random_x: float = randf_range(
		-spawn_radius,
		spawn_radius
	)

	var random_z: float = randf_range(
		-spawn_radius,
		spawn_radius
	)

	bot_instance.global_position = Vector3(
		random_x,
		1.0,
		random_z
	)

	bot_instance.name = (
		"Practice_Bot_" +
		str(randi() % 1000)
	)

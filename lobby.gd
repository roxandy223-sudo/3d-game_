extends Control

var selected_mode = "Practice Range"


func _ready() -> void:
	create_lobby()


func create_lobby() -> void:

	var background = ColorRect.new()
	background.color = Color(0.02, 0.025, 0.045)
	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	add_child(background)

	var title = Label.new()
	title.text = "SELECT GAME MODE"
	title.position = Vector2(0, 70)
	title.size = Vector2(1280, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	add_child(title)

	var practice = Button.new()
	practice.text = "PRACTICE RANGE"
	practice.position = Vector2(100, 200)
	practice.size = Vector2(300, 180)
	add_child(practice)

	practice.pressed.connect(
		func():
			selected_mode = "Practice Range"
	)

	var deathmatch = Button.new()
	deathmatch.text = "DEATHMATCH"
	deathmatch.position = Vector2(490, 200)
	deathmatch.size = Vector2(300, 180)
	add_child(deathmatch)

	deathmatch.pressed.connect(
		func():
			selected_mode = "Deathmatch"
	)

	var aim = Button.new()
	aim.text = "AIM TRAINING"
	aim.position = Vector2(880, 200)
	aim.size = Vector2(300, 180)
	add_child(aim)

	aim.pressed.connect(
		func():
			selected_mode = "Aim Training"
	)

	var play = Button.new()
	play.text = "PLAY"
	play.position = Vector2(440, 500)
	play.size = Vector2(400, 80)
	add_child(play)

	play.pressed.connect(start_game)


func start_game() -> void:

	get_tree().set_meta(
		"selected_mode",
		selected_mode
	)

	get_tree().change_scene_to_file(
		"res://AgentSelect.tscn"
	)

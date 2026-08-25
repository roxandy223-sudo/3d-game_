extends Control

var selected_mode: String = "Practice Range"

var title_label: Label
var selected_label: Label

var practice_button: Button
var deathmatch_button: Button
var aim_button: Button
var play_button: Button


func _ready() -> void:
	create_lobby()


func create_lobby() -> void:

	# Background
	var background := ColorRect.new()

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.color = Color(
		0.025,
		0.03,
		0.05
	)

	add_child(background)


	# Main panel
	var panel := ColorRect.new()

	panel.position = Vector2(80, 60)
	panel.size = Vector2(1120, 600)

	panel.color = Color(
		0.06,
		0.07,
		0.10
	)

	add_child(panel)


	# Title
	title_label = Label.new()

	title_label.text = "SELECT GAME MODE"

	title_label.position = Vector2(
		0,
		35
	)

	title_label.size = Vector2(
		1120,
		60
	)

	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	title_label.add_theme_font_size_override(
		"font_size",
		36
	)

	panel.add_child(title_label)


	# Subtitle
	var subtitle := Label.new()

	subtitle.text = "CHOOSE YOUR MODE"

	subtitle.position = Vector2(
		0,
		95
	)

	subtitle.size = Vector2(
		1120,
		40
	)

	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	subtitle.add_theme_font_size_override(
		"font_size",
		16
	)

	panel.add_child(subtitle)


	# Practice Range
	practice_button = create_mode_button(
		"Practice Range",
		"Train against bots"
	)

	practice_button.position = Vector2(
		70,
		170
	)

	panel.add_child(practice_button)

	practice_button.pressed.connect(
		select_practice
	)


	# Deathmatch
	deathmatch_button = create_mode_button(
		"Deathmatch",
		"Fight waves of bots"
	)

	deathmatch_button.position = Vector2(
		420,
		170
	)

	panel.add_child(deathmatch_button)

	deathmatch_button.pressed.connect(
		select_deathmatch
	)


	# Aim Training
	aim_button = create_mode_button(
		"Aim Training",
		"Shoot targets"
	)

	aim_button.position = Vector2(
		770,
		170
	)

	panel.add_child(aim_button)

	aim_button.pressed.connect(
		select_aim
	)


	# Selected mode
	selected_label = Label.new()

	selected_label.text = "SELECTED: PRACTICE RANGE"

	selected_label.position = Vector2(
		0,
		390
	)

	selected_label.size = Vector2(
		1120,
		40
	)

	selected_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	selected_label.add_theme_font_size_override(
		"font_size",
		20
	)

	panel.add_child(selected_label)


	# Play button
	play_button = Button.new()

	play_button.text = "PLAY"

	play_button.position = Vector2(
		380,
		470
	)

	play_button.size = Vector2(
		360,
		70
	)

	play_button.add_theme_font_size_override(
		"font_size",
		25
	)

	panel.add_child(play_button)

	play_button.pressed.connect(
		start_game
	)


	update_buttons()


func create_mode_button(
	mode_name: String,
	description: String
) -> Button:

	var button := Button.new()

	button.text = (
		mode_name +
		"\n\n" +
		description
	)

	button.size = Vector2(
		280,
		170
	)

	button.add_theme_font_size_override(
		"font_size",
		20
	)

	return button


func select_practice() -> void:

	selected_mode = "Practice Range"

	selected_label.text = (
		"SELECTED: PRACTICE RANGE"
	)

	update_buttons()


func select_deathmatch() -> void:

	selected_mode = "Deathmatch"

	selected_label.text = (
		"SELECTED: DEATHMATCH"
	)

	update_buttons()


func select_aim() -> void:

	selected_mode = "Aim Training"

	selected_label.text = (
		"SELECTED: AIM TRAINING"
	)

	update_buttons()


func update_buttons() -> void:

	practice_button.modulate = Color.WHITE
	deathmatch_button.modulate = Color.WHITE
	aim_button.modulate = Color.WHITE

	if selected_mode == "Practice Range":
		practice_button.modulate = Color(
			1.0,
			0.8,
			0.3
		)

	elif selected_mode == "Deathmatch":
		deathmatch_button.modulate = Color(
			1.0,
			0.8,
			0.3
		)

	elif selected_mode == "Aim Training":
		aim_button.modulate = Color(
			1.0,
			0.8,
			0.3
		)


func start_game() -> void:

	# Make sure GameSettings exists.
	if has_node("/root/GameSettings"):

		GameSettings.selected_mode = selected_mode

	print(
		"Starting: ",
		selected_mode
	)

	get_tree().change_scene_to_file(
		"res://world.tscn"
	)

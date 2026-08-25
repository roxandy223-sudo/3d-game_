extends Control

var selected_mode = "Practice Range"
var selected_agent = "Jett"

var title_label
var mode_label

var practice_button
var deathmatch_button
var aim_button

var jett_button
var reyna_button
var omen_button

var next_button


func _ready():

	# Mouse is visible while using menus.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	show_mode_menu()


# ============================================================
# CLEAR
# ============================================================

func clear_menu():

	for child in get_children():

		child.queue_free()


# ============================================================
# BACKGROUND
# ============================================================

func create_background():

	var background = ColorRect.new()

	background.color = Color(
		0.015,
		0.02,
		0.035,
		0.98
	)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(background)


# ============================================================
# TITLE
# ============================================================

func create_title(text):

	title_label = Label.new()

	title_label.text = text

	title_label.position = Vector2(
		0,
		60
	)

	title_label.size = Vector2(
		1280,
		60
	)

	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title_label.add_theme_font_size_override(
		"font_size",
		40
	)

	add_child(title_label)


# ============================================================
# GAME MODE MENU
# ============================================================

func show_mode_menu():

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	clear_menu()

	await get_tree().process_frame

	create_background()

	create_title(
		"SELECT GAME MODE"
	)


	# Practice Range
	practice_button = Button.new()

	practice_button.text = "PRACTICE RANGE"

	practice_button.position = Vector2(
		100,
		220
	)

	practice_button.size = Vector2(
		300,
		200
	)

	practice_button.add_theme_font_size_override(
		"font_size",
		22
	)

	add_child(practice_button)

	practice_button.pressed.connect(
		select_practice
	)


	# Deathmatch
	deathmatch_button = Button.new()

	deathmatch_button.text = "DEATHMATCH"

	deathmatch_button.position = Vector2(
		490,
		220
	)

	deathmatch_button.size = Vector2(
		300,
		200
	)

	deathmatch_button.add_theme_font_size_override(
		"font_size",
		22
	)

	add_child(deathmatch_button)

	deathmatch_button.pressed.connect(
		select_deathmatch
	)


	# Aim Training
	aim_button = Button.new()

	aim_button.text = "AIM TRAINING"

	aim_button.position = Vector2(
		880,
		220
	)

	aim_button.size = Vector2(
		300,
		200
	)

	aim_button.add_theme_font_size_override(
		"font_size",
		22
	)

	add_child(aim_button)

	aim_button.pressed.connect(
		select_aim
	)


# ============================================================
# MODE SELECT
# ============================================================

func select_practice():

	selected_mode = "Practice Range"

	show_agent_menu()


func select_deathmatch():

	selected_mode = "Deathmatch"

	show_agent_menu()


func select_aim():

	selected_mode = "Aim Training"

	show_agent_menu()


# ============================================================
# AGENT MENU
# ============================================================

func show_agent_menu():

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	clear_menu()

	await get_tree().process_frame

	create_background()

	create_title(
		"SELECT YOUR AGENT"
	)


	# Jett
	jett_button = Button.new()

	jett_button.text = "JETT"

	jett_button.position = Vector2(
		100,
		220
	)

	jett_button.size = Vector2(
		300,
		220
	)

	jett_button.add_theme_font_size_override(
		"font_size",
		25
	)

	add_child(jett_button)

	jett_button.pressed.connect(
		select_jett
	)


	# Reyna
	reyna_button = Button.new()

	reyna_button.text = "REYNA"

	reyna_button.position = Vector2(
		490,
		220
	)

	reyna_button.size = Vector2(
		300,
		220
	)

	reyna_button.add_theme_font_size_override(
		"font_size",
		25
	)

	add_child(reyna_button)

	reyna_button.pressed.connect(
		select_reyna
	)


	# Omen
	omen_button = Button.new()

	omen_button.text = "OMEN"

	omen_button.position = Vector2(
		880,
		220
	)

	omen_button.size = Vector2(
		300,
		220
	)

	omen_button.add_theme_font_size_override(
		"font_size",
		25
	)

	add_child(omen_button)

	omen_button.pressed.connect(
		select_omen
	)


	# Lock In
	next_button = Button.new()

	next_button.text = "LOCK IN"

	next_button.position = Vector2(
		440,
		520
	)

	next_button.size = Vector2(
		400,
		75
	)

	next_button.add_theme_font_size_override(
		"font_size",
		26
	)

	add_child(next_button)

	next_button.pressed.connect(
		lock_in
	)

	update_agent_highlight()


# ============================================================
# AGENT SELECT
# ============================================================

func select_jett():

	selected_agent = "Jett"

	update_agent_highlight()


func select_reyna():

	selected_agent = "Reyna"

	update_agent_highlight()


func select_omen():

	selected_agent = "Omen"

	update_agent_highlight()


# ============================================================
# AGENT HIGHLIGHT
# ============================================================

func update_agent_highlight():

	if jett_button == null:
		return

	jett_button.modulate = Color.WHITE
	reyna_button.modulate = Color.WHITE
	omen_button.modulate = Color.WHITE

	if selected_agent == "Jett":

		jett_button.modulate = Color(
			0.4,
			0.8,
			1.0
		)

	elif selected_agent == "Reyna":

		reyna_button.modulate = Color(
			0.75,
			0.35,
			1.0
		)

	elif selected_agent == "Omen":

		omen_button.modulate = Color(
			0.45,
			0.35,
			0.9
		)


# ============================================================
# LOCK IN
# ============================================================

func lock_in():

	print(
		"MODE: ",
		selected_mode
	)

	print(
		"AGENT: ",
		selected_agent
	)

	# Save selections.
	get_tree().set_meta(
		"selected_mode",
		selected_mode
	)

	get_tree().set_meta(
		"selected_agent",
		selected_agent
	)

	# Hide menu.
	visible = false

	# Capture cursor for FPS gameplay.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Tell Player the selected agent.
	var player = get_parent().get_node_or_null(
		"Player"
	)

	if player != null:

		if player.has_method(
			"set_selected_agent"
		):

			player.set_selected_agent(
				selected_agent
			)

extends Control

# ============================================================
# POLISHED FPS HUD
# ============================================================

var player = null

# Top
var top_bar
var left_score
var right_score
var round_timer
var round_label
var kills_label

# Minimap
var minimap_panel
var minimap_title

# Bottom left
var health_value
var health_bar
var armor_value

# Bottom center
var ability_row

# Bottom right
var weapon_panel
var weapon_name
var ammo_value
var reserve_value


# ============================================================
# AGENT ABILITIES
# ============================================================

var agent_abilities = {

	"Jett": {
		"C": "Cloudburst",
		"Q": "Updraft",
		"E": "Tailwind",
		"X": "Blade Storm"
	},

	"Reyna": {
		"C": "Leer",
		"Q": "Devour",
		"E": "Dismiss",
		"X": "Empress"
	},

	"Omen": {
		"C": "Shrouded Step",
		"Q": "Paranoia",
		"E": "Dark Cover",
		"X": "From the Shadows"
	}
}


# ============================================================
# READY
# ============================================================

func _ready():

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_IGNORE

	player = get_parent().get_node_or_null(
		"Player"
	)

	build_hud()

	get_viewport().size_changed.connect(
		update_layout
	)

	update_layout()
	update_hud()


# ============================================================
# PROCESS
# ============================================================

func _process(_delta):

	update_hud()


# ============================================================
# BUILD HUD
# ============================================================

func build_hud():

	build_top_bar()

	build_minimap()

	build_health()

	build_abilities()

	build_weapon()


# ============================================================
# TOP BAR
# ============================================================

func build_top_bar():

	var bar = ColorRect.new()

	bar.name = "TopBar"

	bar.color = Color(
		0.02,
		0.025,
		0.04,
		0.82
	)

	bar.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(bar)


	left_score = make_label(
		"0",
		26
	)

	bar.add_child(left_score)


	round_timer = make_label(
		"1:30",
		24
	)

	bar.add_child(round_timer)


	right_score = make_label(
		"0",
		26
	)

	bar.add_child(right_score)


	round_label = make_label(
		"ROUND 1",
		10
	)

	bar.add_child(round_label)


	kills_label = make_label(
		"K 0",
		11
	)

	bar.add_child(kills_label)


# ============================================================
# MINIMAP
# ============================================================

func build_minimap():

	minimap_panel = Panel.new()

	minimap_panel.name = "Minimap"

	add_child(minimap_panel)


	var style = StyleBoxFlat.new()

	style.bg_color = Color(
		0.055,
		0.065,
		0.085,
		0.94
	)

	style.border_color = Color(
		0.22,
		0.24,
		0.29,
		0.9
	)

	style.set_border_width_all(1)

	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4

	minimap_panel.add_theme_stylebox_override(
		"panel",
		style
	)


	minimap_title = make_label(
		"MAP",
		10
	)

	minimap_title.position = Vector2(
		10,
		7
	)

	minimap_panel.add_child(
		minimap_title
	)


	var map_text = make_label(
		"+----------------+\n" +
		"|      MAP       |\n" +
		"|  +----+----+   |\n" +
		"|  |    |    |   |\n" +
		"|  +----+----+   |\n" +
		"|       +        |\n" +
		"|     PLAYER     |\n" +
		"+----------------+",
		10
	)

	map_text.position = Vector2(
		10,
		30
	)

	minimap_panel.add_child(
		map_text
	)


# ============================================================
# HEALTH
# ============================================================

func build_health():

	health_bar = ProgressBar.new()

	health_bar.max_value = 100
	health_bar.value = 100

	health_bar.show_percentage = false

	add_child(
		health_bar
	)


	var background_style = StyleBoxFlat.new()

	background_style.bg_color = Color(
		0.07,
		0.08,
		0.10
	)

	health_bar.add_theme_stylebox_override(
		"background",
		background_style
	)


	var health_style = StyleBoxFlat.new()

	health_style.bg_color = Color(
		0.88,
		0.90,
		0.94
	)

	health_bar.add_theme_stylebox_override(
		"fill",
		health_style
	)


	health_value = make_label(
		"100",
		30
	)

	add_child(
		health_value
	)


	armor_value = make_label(
		"0",
		16
	)

	add_child(
		armor_value
	)


# ============================================================
# ABILITIES
# ============================================================

func build_abilities():

	ability_row = HBoxContainer.new()

	ability_row.name = "AbilityRow"

	ability_row.add_theme_constant_override(
		"separation",
		7
	)

	add_child(
		ability_row
	)

	update_ability_names()


func update_ability_names():

	if ability_row == null:
		return


	for child in ability_row.get_children():

		child.queue_free()


	await get_tree().process_frame


	var agent_name = get_player_agent_name()

	if not agent_abilities.has(agent_name):

		agent_name = "Jett"


	var abilities = agent_abilities[
		agent_name
	]


	for key in ["C", "Q", "E", "X"]:

		var panel = create_ability_panel(
			key,
			abilities[key]
		)

		ability_row.add_child(
			panel
		)


# ============================================================
# GET PLAYER AGENT
# ============================================================

func get_player_agent_name():

	if player == null:

		return "Jett"


	if player.has_method(
		"get_selected_agent_name"
	):

		return player.get_selected_agent_name()


	if "selected_agent" in player:

		match player.selected_agent:

			1:
				return "Jett"

			2:
				return "Reyna"

			3:
				return "Omen"


	return "Jett"


# ============================================================
# ABILITY PANEL
# ============================================================

func create_ability_panel(
	key,
	ability_name
):

	var panel = Panel.new()

	panel.custom_minimum_size = Vector2(
		105,
		68
	)


	var style = StyleBoxFlat.new()

	style.bg_color = Color(
		0.055,
		0.06,
		0.075,
		0.96
	)

	style.border_color = Color(
		0.24,
		0.25,
		0.28,
		0.9
	)

	style.set_border_width_all(1)

	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3

	panel.add_theme_stylebox_override(
		"panel",
		style
	)


	var key_label = make_label(
		key,
		11
	)

	key_label.position = Vector2(
		6,
		4
	)

	key_label.size = Vector2(
		25,
		18
	)

	panel.add_child(
		key_label
	)


	var ability_label = make_label(
		ability_name,
		10
	)

	ability_label.position = Vector2(
		5,
		24
	)

	ability_label.size = Vector2(
		95,
		36
	)

	ability_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	ability_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	panel.add_child(
		ability_label
	)


	return panel


# ============================================================
# WEAPON PANEL
# ============================================================

func build_weapon():

	weapon_panel = Panel.new()

	weapon_panel.name = "WeaponPanel"

	add_child(
		weapon_panel
	)


	var style = StyleBoxFlat.new()

	style.bg_color = Color(
		0.045,
		0.05,
		0.065,
		0.93
	)

	style.border_color = Color(
		0.20,
		0.22,
		0.25,
		0.85
	)

	style.set_border_width_all(1)

	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4

	weapon_panel.add_theme_stylebox_override(
		"panel",
		style
	)


	weapon_name = make_label(
		"VANDAL",
		19
	)

	weapon_panel.add_child(
		weapon_name
	)


	ammo_value = make_label(
		"25",
		31
	)

	weapon_panel.add_child(
		ammo_value
	)


	reserve_value = make_label(
		"/ 75",
		14
	)

	weapon_panel.add_child(
		reserve_value
	)


# ============================================================
# RESPONSIVE LAYOUT
# ============================================================

func update_layout():

	var size = get_viewport_rect().size

	var w = size.x
	var h = size.y


	# --------------------------------------------------------
	# TOP
	# --------------------------------------------------------

	var top = get_node_or_null(
		"TopBar"
	)

	if top != null:

		top.position = Vector2(
			0,
			0
		)

		top.size = Vector2(
			w,
			60
		)


	left_score.position = Vector2(
		w * 0.43,
		12
	)

	left_score.size = Vector2(
		45,
		35
	)


	round_timer.position = Vector2(
		w * 0.47,
		10
	)

	round_timer.size = Vector2(
		w * 0.06,
		32
	)


	right_score.position = Vector2(
		w * 0.54,
		12
	)

	right_score.size = Vector2(
		45,
		35
	)


	round_label.position = Vector2(
		w * 0.47,
		38
	)

	round_label.size = Vector2(
		w * 0.06,
		16
	)


	kills_label.position = Vector2(
		w - 90,
		17
	)

	kills_label.size = Vector2(
		70,
		22
	)


	# --------------------------------------------------------
	# MINIMAP
	# --------------------------------------------------------

	var map_size = clamp(
		w * 0.155,
		150.0,
		210.0
	)


	minimap_panel.position = Vector2(
		16,
		16
	)


	minimap_panel.size = Vector2(
		map_size,
		map_size
	)


	# --------------------------------------------------------
	# HEALTH
	# --------------------------------------------------------

	health_bar.position = Vector2(
		32,
		h - 42
	)

	health_bar.size = Vector2(
		135,
		8
	)


	health_value.position = Vector2(
		32,
		h - 82
	)

	health_value.size = Vector2(
		85,
		36
	)


	armor_value.position = Vector2(
		122,
		h - 79
	)

	armor_value.size = Vector2(
		40,
		28
	)


	# --------------------------------------------------------
	# ABILITY BAR
	# --------------------------------------------------------

	var ability_width = (
		105.0 * 4.0 +
		7.0 * 3.0
	)


	ability_row.position = Vector2(
		(w * 0.5) -
		(ability_width * 0.5),
		h - 88
	)


	# --------------------------------------------------------
	# WEAPON
	# --------------------------------------------------------

	var weapon_width = clamp(
		w * 0.18,
		205.0,
		255.0
	)


	weapon_panel.position = Vector2(
		w - weapon_width - 20,
		h - 105
	)


	weapon_panel.size = Vector2(
		weapon_width,
		85
	)


	weapon_name.position = Vector2(
		10,
		7
	)

	weapon_name.size = Vector2(
		weapon_width - 20,
		26
	)

	weapon_name.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)


	ammo_value.position = Vector2(
		10,
		33
	)

	ammo_value.size = Vector2(
		weapon_width - 75,
		45
	)

	ammo_value.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)


	reserve_value.position = Vector2(
		weapon_width - 67,
		50
	)

	reserve_value.size = Vector2(
		52,
		25
	)


# ============================================================
# UPDATE
# ============================================================

func update_hud():

	if player == null:

		player = get_parent().get_node_or_null(
			"Player"
		)

		if player == null:
			return


	# --------------------------------------------------------
	# HEALTH
	# --------------------------------------------------------

	if "health" in player:

		health_value.text = str(
			int(player.health)
		)

		health_bar.value = player.health

	elif "current_health" in player:

		health_value.text = str(
			int(player.current_health)
		)

		health_bar.value = player.current_health

	else:

		health_value.text = "100"

		health_bar.value = 100


	# --------------------------------------------------------
	# ARMOR
	# --------------------------------------------------------

	if "armor" in player:

		armor_value.text = str(
			int(player.armor)
		)

	else:

		armor_value.text = "0"


	# --------------------------------------------------------
	# WEAPON
	# --------------------------------------------------------

	if "current_weapon" in player:

		if player.current_weapon == 0:

			weapon_name.text = "VANDAL"

		else:

			weapon_name.text = "KARAMBIT"


	# --------------------------------------------------------
	# AMMO
	# --------------------------------------------------------

	if "ammo" in player:

		ammo_value.text = str(
			player.ammo
		)


	# --------------------------------------------------------
	# KILLS
	# --------------------------------------------------------

	if "kills" in player:

		kills_label.text = (
			"K " +
			str(player.kills)
		)


# ============================================================
# LABEL
# ============================================================

func make_label(
	text_value,
	font_size
):

	var label = Label.new()

	label.text = text_value

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.add_theme_color_override(
		"font_color",
		Color(
			0.92,
			0.93,
			0.95
		)
	)

	return label

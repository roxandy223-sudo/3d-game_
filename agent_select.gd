extends Control

var selected_agent = "Jett"


func _ready() -> void:
	create_screen()


func create_screen() -> void:

	var background = ColorRect.new()
	background.color = Color(0.02, 0.025, 0.045)
	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	add_child(background)

	var title = Label.new()
	title.text = "SELECT YOUR AGENT"
	title.position = Vector2(0, 70)
	title.size = Vector2(1280, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	add_child(title)

	var jett = Button.new()
	jett.text = "JETT\n\nTailwind"
	jett.position = Vector2(100, 220)
	jett.size = Vector2(300, 220)
	add_child(jett)

	jett.pressed.connect(
		func():
			selected_agent = "Jett"
	)

	var reyna = Button.new()
	reyna.text = "REYNA\n\nDevour"
	reyna.position = Vector2(490, 220)
	reyna.size = Vector2(300, 220)
	add_child(reyna)

	reyna.pressed.connect(
		func():
			selected_agent = "Reyna"
	)

	var omen = Button.new()
	omen.text = "OMEN\n\nShrouded Step"
	omen.position = Vector2(880, 220)
	omen.size = Vector2(300, 220)
	add_child(omen)

	omen.pressed.connect(
		func():
			selected_agent = "Omen"
	)

	var lock_in = Button.new()
	lock_in.text = "LOCK IN"
	lock_in.position = Vector2(440, 520)
	lock_in.size = Vector2(400, 80)
	add_child(lock_in)

	lock_in.pressed.connect(lock_agent)


func lock_agent() -> void:

	get_tree().set_meta(
		"selected_agent",
		selected_agent
	)

	get_tree().change_scene_to_file(
		"res://world.tscn"
	)

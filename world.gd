extends Node3D

# ============================================================
# BIG PRACTICE MAP
# Attach this script to the World node
# ============================================================

const MAP_WIDTH = 140.0
const MAP_LENGTH = 120.0
const WALL_HEIGHT = 10.0
const WALL_THICKNESS = 1.0

var map_root: Node3D

var wall_material: StandardMaterial3D
var floor_material: StandardMaterial3D
var cover_material: StandardMaterial3D
var ramp_material: StandardMaterial3D


func _ready():

	# Remove the old map
	delete_old_map()

	create_materials()

	map_root = Node3D.new()
	map_root.name = "BigPracticeMap"
	add_child(map_root)

	create_floor()
	create_outer_walls()

	create_main_lanes()
	create_side_lanes()

	create_cover()
	create_boxes()

	create_ramps()
	create_high_platforms()

	create_spawn_area()
	create_bot_area()

	create_bots()

	print("======================================")
	print("BIG PRACTICE MAP LOADED")
	print("MAP SIZE: 140 x 120")
	print("======================================")


# ============================================================
# DELETE OLD MAP
# ============================================================

func delete_old_map():

	var old_names = [
		"Wall",
		"Wall2",
		"Wall3",
		"Wall4",
		"Floor",
		"ExpandedPracticeMap",
		"PracticeMap"
	]

	for node_name in old_names:

		var node = get_node_or_null(node_name)

		if node != null:

			node.queue_free()


# ============================================================
# MATERIALS
# ============================================================

func create_materials():

	floor_material = StandardMaterial3D.new()

	floor_material.albedo_color = Color(
		0.08,
		0.09,
		0.11
	)

	floor_material.roughness = 0.9


	wall_material = StandardMaterial3D.new()

	wall_material.albedo_color = Color(
		0.18,
		0.20,
		0.24
	)

	wall_material.roughness = 0.8


	cover_material = StandardMaterial3D.new()

	cover_material.albedo_color = Color(
		0.30,
		0.33,
		0.38
	)

	cover_material.roughness = 0.7


	ramp_material = StandardMaterial3D.new()

	ramp_material.albedo_color = Color(
		0.22,
		0.25,
		0.29
	)

	ramp_material.roughness = 0.75


# ============================================================
# FLOOR
# ============================================================

func create_floor():

	create_box(
		"BigFloor",
		Vector3(
			MAP_WIDTH,
			0.5,
			MAP_LENGTH
		),
		Vector3(
			0.0,
			-0.25,
			0.0
		),
		floor_material
	)


# ============================================================
# OUTER WALLS
# ============================================================

func create_outer_walls():

	# North
	create_box(
		"NorthWall",
		Vector3(
			MAP_WIDTH,
			WALL_HEIGHT,
			WALL_THICKNESS
		),
		Vector3(
			0.0,
			WALL_HEIGHT / 2.0,
			-MAP_LENGTH / 2.0
		),
		wall_material
	)

	# South
	create_box(
		"SouthWall",
		Vector3(
			MAP_WIDTH,
			WALL_HEIGHT,
			WALL_THICKNESS
		),
		Vector3(
			0.0,
			WALL_HEIGHT / 2.0,
			MAP_LENGTH / 2.0
		),
		wall_material
	)

	# West
	create_box(
		"WestWall",
		Vector3(
			WALL_THICKNESS,
			WALL_HEIGHT,
			MAP_LENGTH
		),
		Vector3(
			-MAP_WIDTH / 2.0,
			WALL_HEIGHT / 2.0,
			0.0
		),
		wall_material
	)

	# East
	create_box(
		"EastWall",
		Vector3(
			WALL_THICKNESS,
			WALL_HEIGHT,
			MAP_LENGTH
		),
		Vector3(
			MAP_WIDTH / 2.0,
			WALL_HEIGHT / 2.0,
			0.0
		),
		wall_material
	)


# ============================================================
# MAIN LANES
# ============================================================

func create_main_lanes():

	# LEFT LANE
	create_box(
		"LeftLaneWall",
		Vector3(1.0, 4.0, 75.0),
		Vector3(-45.0, 2.0, -5.0),
		wall_material
	)

	create_box(
		"LeftLaneWall2",
		Vector3(1.0, 4.0, 75.0),
		Vector3(-15.0, 2.0, -5.0),
		wall_material
	)


	# CENTER LANE
	create_box(
		"CenterLaneWall",
		Vector3(1.0, 4.0, 75.0),
		Vector3(-7.0, 2.0, -5.0),
		wall_material
	)

	create_box(
		"CenterLaneWall2",
		Vector3(1.0, 4.0, 75.0),
		Vector3(23.0, 2.0, -5.0),
		wall_material
	)


	# RIGHT LANE
	create_box(
		"RightLaneWall",
		Vector3(1.0, 4.0, 75.0),
		Vector3(31.0, 2.0, -5.0),
		wall_material
	)

	create_box(
		"RightLaneWall2",
		Vector3(1.0, 4.0, 75.0),
		Vector3(58.0, 2.0, -5.0),
		wall_material
	)


# ============================================================
# SIDE LANES
# ============================================================

func create_side_lanes():

	# LEFT CROSS LANE

	create_box(
		"LeftCrossWall",
		Vector3(35.0, 3.5, 1.0),
		Vector3(-42.0, 1.75, 15.0),
		wall_material
	)


	# RIGHT CROSS LANE

	create_box(
		"RightCrossWall",
		Vector3(35.0, 3.5, 1.0),
		Vector3(42.0, 1.75, 15.0),
		wall_material
	)


	# BACK CROSS LANE

	create_box(
		"BackLaneWall",
		Vector3(90.0, 3.5, 1.0),
		Vector3(0.0, 1.75, -35.0),
		wall_material
	)


# ============================================================
# COVER
# ============================================================

func create_cover():

	# LOW COVER

	create_box(
		"LowCover1",
		Vector3(6.0, 1.2, 2.5),
		Vector3(-35.0, 0.6, 18.0),
		cover_material
	)

	create_box(
		"LowCover2",
		Vector3(6.0, 1.2, 2.5),
		Vector3(-5.0, 0.6, 12.0),
		cover_material
	)

	create_box(
		"LowCover3",
		Vector3(6.0, 1.2, 2.5),
		Vector3(28.0, 0.6, 20.0),
		cover_material
	)

	create_box(
		"LowCover4",
		Vector3(6.0, 1.2, 2.5),
		Vector3(52.0, 0.6, 8.0),
		cover_material
	)


	# TALL COVER

	create_box(
		"TallCover1",
		Vector3(4.0, 4.0, 3.0),
		Vector3(-52.0, 2.0, 20.0),
		cover_material
	)

	create_box(
		"TallCover2",
		Vector3(4.0, 4.0, 3.0),
		Vector3(-22.0, 2.0, 25.0),
		cover_material
	)

	create_box(
		"TallCover3",
		Vector3(4.0, 4.0, 3.0),
		Vector3(15.0, 2.0, 22.0),
		cover_material
	)

	create_box(
		"TallCover4",
		Vector3(4.0, 4.0, 3.0),
		Vector3(45.0, 2.0, 25.0),
		cover_material
	)


# ============================================================
# BOXES
# ============================================================

func create_boxes():

	for i in range(4):

		create_box(
			"BoxLeft" + str(i),
			Vector3(3.0, 3.0, 3.0),
			Vector3(
				-50.0 + i * 5.0,
				1.5,
				-20.0
			),
			cover_material
		)


	for i in range(4):

		create_box(
			"BoxRight" + str(i),
			Vector3(3.0, 3.0, 3.0),
			Vector3(
				30.0 + i * 5.0,
				1.5,
				-20.0
			),
			cover_material
		)


# ============================================================
# RAMPS
# ============================================================

func create_ramps():

	create_ramp(
		"LeftRamp",
		Vector3(10.0, 2.0, 14.0),
		Vector3(-42.0, 1.0, 30.0),
		-12.0
	)

	create_ramp(
		"RightRamp",
		Vector3(10.0, 2.0, 14.0),
		Vector3(42.0, 1.0, 30.0),
		12.0
	)


# ============================================================
# HIGH PLATFORMS
# ============================================================

func create_high_platforms():

	create_box(
		"HighPlatformLeft",
		Vector3(18.0, 2.0, 10.0),
		Vector3(-35.0, 5.0, 32.0),
		wall_material
	)

	create_box(
		"HighPlatformRight",
		Vector3(18.0, 2.0, 10.0),
		Vector3(35.0, 5.0, 32.0),
		wall_material
	)

	# Platform supports

	create_box(
		"PlatformSupport1",
		Vector3(2.0, 5.0, 2.0),
		Vector3(-42.0, 2.5, 32.0),
		wall_material
	)

	create_box(
		"PlatformSupport2",
		Vector3(2.0, 5.0, 2.0),
		Vector3(-28.0, 2.5, 32.0),
		wall_material
	)

	create_box(
		"PlatformSupport3",
		Vector3(2.0, 5.0, 2.0),
		Vector3(28.0, 2.5, 32.0),
		wall_material
	)

	create_box(
		"PlatformSupport4",
		Vector3(2.0, 5.0, 2.0),
		Vector3(42.0, 2.5, 32.0),
		wall_material
	)


# ============================================================
# PLAYER SPAWN
# ============================================================

func create_spawn_area():

	create_box(
		"SpawnBackWall",
		Vector3(40.0, 4.0, 1.0),
		Vector3(0.0, 2.0, 52.0),
		wall_material
	)

	create_box(
		"SpawnLeftWall",
		Vector3(1.0, 4.0, 20.0),
		Vector3(-20.0, 2.0, 42.0),
		wall_material
	)

	create_box(
		"SpawnRightWall",
		Vector3(1.0, 4.0, 20.0),
		Vector3(20.0, 2.0, 42.0),
		wall_material
	)


# ============================================================
# BOT AREA
# ============================================================

func create_bot_area():

	create_box(
		"BotBackWall",
		Vector3(110.0, 5.0, 1.0),
		Vector3(0.0, 2.5, -52.0),
		wall_material
	)


# ============================================================
# BOTS
# ============================================================

func create_bots():

	var bot_scene = load("res://bot.tscn")

	if bot_scene == null:

		print("ERROR: res://bot.tscn not found")

		return

	var positions = [

		Vector3(-50.0, 0.0, -40.0),
		Vector3(-40.0, 0.0, -35.0),
		Vector3(-30.0, 0.0, -42.0),

		Vector3(-15.0, 0.0, -38.0),
		Vector3(-5.0, 0.0, -45.0),

		Vector3(8.0, 0.0, -38.0),
		Vector3(18.0, 0.0, -44.0),

		Vector3(30.0, 0.0, -38.0),
		Vector3(40.0, 0.0, -44.0),
		Vector3(50.0, 0.0, -36.0),

		Vector3(-25.0, 0.0, -25.0),
		Vector3(25.0, 0.0, -25.0)
	]

	for i in range(positions.size()):

		var bot = bot_scene.instantiate()

		bot.name = "Bot_%02d" % i

		bot.position = positions[i]

		add_child(bot)


# ============================================================
# BOX CREATOR
# ============================================================

func create_box(
	node_name,
	size,
	position,
	material
):

	var body = StaticBody3D.new()

	body.name = node_name

	body.position = position

	map_root.add_child(body)


	# Mesh

	var mesh_instance = MeshInstance3D.new()

	var mesh = BoxMesh.new()

	mesh.size = size

	mesh_instance.mesh = mesh

	mesh_instance.material_override = material

	body.add_child(mesh_instance)


	# Collision

	var collision = CollisionShape3D.new()

	var shape = BoxShape3D.new()

	shape.size = size

	collision.shape = shape

	body.add_child(collision)

	return body


# ============================================================
# RAMP CREATOR
# ============================================================

func create_ramp(
	node_name,
	size,
	position,
	angle
):

	var body = StaticBody3D.new()

	body.name = node_name

	body.position = position

	body.rotation_degrees.z = angle

	map_root.add_child(body)


	var mesh_instance = MeshInstance3D.new()

	var mesh = BoxMesh.new()

	mesh.size = size

	mesh_instance.mesh = mesh

	mesh_instance.material_override = ramp_material

	body.add_child(mesh_instance)


	var collision = CollisionShape3D.new()

	var shape = BoxShape3D.new()

	shape.size = size

	collision.shape = shape

	body.add_child(collision)

	return body

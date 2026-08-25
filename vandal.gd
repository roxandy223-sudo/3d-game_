extends Node3D

const DAMAGE = 30.0
const RANGE = 300.0
const FIRE_DELAY = 0.10

var fire_timer = 0.0


func _ready():
	create_vandal_model()


func _process(delta):

	if fire_timer > 0.0:
		fire_timer -= delta

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		shoot()


func shoot():

	if fire_timer > 0.0:
		return

	fire_timer = FIRE_DELAY

	var camera = get_viewport().get_camera_3d()

	if camera == null:
		return

	# Exact centre of the screen
	var screen_size = get_viewport().get_visible_rect().size
	var center = screen_size / 2.0

	var ray_start = camera.project_ray_origin(center)
	var ray_direction = camera.project_ray_normal(center)
	var ray_end = ray_start + ray_direction * RANGE

	var query = PhysicsRayQueryParameters3D.create(
		ray_start,
		ray_end
	)

	# Ignore player
	var player = camera.get_parent()

	if player != null:
		query.exclude = [player]

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		print("MISS")
		return

	var target = result["collider"]

	print("HIT: ", target.name)

	damage_target(target)


func damage_target(target):

	if target == null:
		return

	if target.has_method("take_damage"):

		target.take_damage(DAMAGE)

		print("DAMAGE: ", DAMAGE)

		return

	var current = target

	while current != null:

		current = current.get_parent()

		if current == null:
			break

		if current.has_method("take_damage"):

			current.take_damage(DAMAGE)

			print("DAMAGE: ", DAMAGE)

			return


func create_vandal_model():

	# Main rifle body
	var body = MeshInstance3D.new()

	var body_mesh = BoxMesh.new()

	body_mesh.size = Vector3(
		0.22,
		0.20,
		0.75
	)

	body.mesh = body_mesh

	body.position = Vector3(
		0.0,
		0.0,
		-0.45
	)

	var body_material = StandardMaterial3D.new()

	body_material.albedo_color = Color(
		0.9,
		0.88,
		0.78
	)

	body_material.metallic = 0.5

	body.material_override = body_material

	add_child(body)


	# Barrel
	var barrel = MeshInstance3D.new()

	var barrel_mesh = CylinderMesh.new()

	barrel_mesh.top_radius = 0.035
	barrel_mesh.bottom_radius = 0.045
	barrel_mesh.height = 0.65

	barrel.mesh = barrel_mesh

	barrel.rotation_degrees.x = 90.0

	barrel.position = Vector3(
		0.0,
		0.02,
		-0.95
	)

	var barrel_material = StandardMaterial3D.new()

	barrel_material.albedo_color = Color(
		0.12,
		0.12,
		0.13
	)

	barrel_material.metallic = 0.8

	barrel.material_override = barrel_material

	add_child(barrel)


	# Magazine
	var magazine = MeshInstance3D.new()

	var magazine_mesh = BoxMesh.new()

	magazine_mesh.size = Vector3(
		0.13,
		0.38,
		0.16
	)

	magazine.mesh = magazine_mesh

	magazine.position = Vector3(
		0.0,
		-0.22,
		-0.28
	)

	magazine.rotation_degrees.x = -10.0

	magazine.material_override = body_material

	add_child(magazine)


	# Grip
	var grip = MeshInstance3D.new()

	var grip_mesh = BoxMesh.new()

	grip_mesh.size = Vector3(
		0.14,
		0.32,
		0.16
	)

	grip.mesh = grip_mesh

	grip.position = Vector3(
		0.0,
		-0.20,
		0.05
	)

	grip.rotation_degrees.x = -12.0

	grip.material_override = barrel_material

	add_child(grip)


	# Gold accent
	var accent = MeshInstance3D.new()

	var accent_mesh = BoxMesh.new()

	accent_mesh.size = Vector3(
		0.23,
		0.025,
		0.45
	)

	accent.mesh = accent_mesh

	accent.position = Vector3(
		0.0,
		0.115,
		-0.43
	)

	var gold = StandardMaterial3D.new()

	gold.albedo_color = Color(
		0.9,
		0.65,
		0.15
	)

	gold.metallic = 0.8

	accent.material_override = gold

	add_child(accent)

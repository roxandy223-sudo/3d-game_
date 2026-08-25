extends Node3D

# ============================================================
# KARAMBIT
# Attach this script to the Karambit Node3D
#
# Scene:
# Karambit
# ├── AnimationPlayer
# └── ...
# ============================================================

@onready var animation_player: AnimationPlayer = get_node_or_null(
	"AnimationPlayer"
)

var blade: MeshInstance3D
var handle: MeshInstance3D
var ring: MeshInstance3D


func _ready() -> void:

	create_knife()

	if animation_player == null:
		create_animation_player()


# ============================================================
# CREATE KNIFE
# ============================================================

func create_knife() -> void:

	# Don't create duplicates.
	if get_node_or_null("Blade") != null:
		return

	var blade_material := StandardMaterial3D.new()

	blade_material.albedo_color = Color(
		0.75,
		0.78,
		0.82
	)

	blade_material.metallic = 0.9
	blade_material.roughness = 0.15


	var handle_material := StandardMaterial3D.new()

	handle_material.albedo_color = Color(
		0.025,
		0.03,
		0.035
	)

	handle_material.roughness = 0.4


	# ========================================================
	# BLADE
	# ========================================================

	blade = MeshInstance3D.new()

	blade.name = "Blade"

	var blade_mesh := BoxMesh.new()

	blade_mesh.size = Vector3(
		0.07,
		0.16,
		0.55
	)

	blade.mesh = blade_mesh

	blade.position = Vector3(
		0.0,
		0.02,
		-0.28
	)

	blade.rotation_degrees = Vector3(
		0.0,
		0.0,
		-25.0
	)

	blade.material_override = blade_material

	add_child(blade)


	# ========================================================
	# HANDLE
	# ========================================================

	handle = MeshInstance3D.new()

	handle.name = "Handle"

	var handle_mesh := CapsuleMesh.new()

	handle_mesh.radius = 0.065
	handle_mesh.height = 0.36

	handle.mesh = handle_mesh

	handle.position = Vector3(
		0.04,
		-0.02,
		0.18
	)

	handle.rotation_degrees.z = 90.0

	handle.material_override = handle_material

	add_child(handle)


	# ========================================================
	# RING
	# ========================================================

	ring = MeshInstance3D.new()

	ring.name = "Ring"

	var ring_mesh := TorusMesh.new()

	ring_mesh.inner_radius = 0.075
	ring_mesh.outer_radius = 0.12

	ring.mesh = ring_mesh

	ring.position = Vector3(
		0.04,
		-0.02,
		0.39
	)

	ring.rotation_degrees.x = 90.0

	ring.material_override = handle_material

	add_child(ring)


# ============================================================
# ANIMATION PLAYER
# ============================================================

func create_animation_player() -> void:

	animation_player = AnimationPlayer.new()

	animation_player.name = "AnimationPlayer"

	add_child(animation_player)

	var library := AnimationLibrary.new()

	animation_player.add_animation_library(
		"",
		library
	)

	var animation := Animation.new()

	animation.length = 0.20

	# Position track.
	var position_track := animation.add_track(
		Animation.TYPE_VALUE
	)

	animation.track_set_path(
		position_track,
		NodePath(".:position")
	)

	animation.track_insert_key(
		position_track,
		0.0,
		Vector3(
			0.20,
			-0.30,
			-0.65
		)
	)

	animation.track_insert_key(
		position_track,
		0.10,
		Vector3(
			0.02,
			-0.20,
			-0.52
		)
	)

	animation.track_insert_key(
		position_track,
		0.20,
		Vector3(
			0.20,
			-0.30,
			-0.65
		)
	)


	# Rotation track.
	var rotation_track := animation.add_track(
		Animation.TYPE_VALUE
	)

	animation.track_set_path(
		rotation_track,
		NodePath(".:rotation_degrees")
	)

	animation.track_insert_key(
		rotation_track,
		0.0,
		Vector3(
			-8.0,
			15.0,
			-8.0
		)
	)

	animation.track_insert_key(
		rotation_track,
		0.10,
		Vector3(
			-30.0,
			25.0,
			-80.0
		)
	)

	animation.track_insert_key(
		rotation_track,
		0.20,
		Vector3(
			-8.0,
			15.0,
			-8.0
		)
	)

	library.add_animation(
		"Karambit_Slash",
		animation
	)


# ============================================================
# PLAY SLASH
# ============================================================

func slash() -> void:

	if animation_player == null:
		return

	if animation_player.has_animation(
		"Karambit_Slash"
	):

		animation_player.play(
			"Karambit_Slash"
	)

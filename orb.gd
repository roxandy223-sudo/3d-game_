extends Area3D

var collected := false
var visual: MeshInstance3D
var spin := 0.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	create_visual()

func create_visual() -> void:
	visual = MeshInstance3D.new()
	visual.name = "OrbVisual"
	var mesh := SphereMesh.new()
	mesh.radius = 0.28
	mesh.height = 0.56
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.20, 0.75, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.05, 0.55, 1.0)
	material.emission_energy_multiplier = 2.5
	visual.material_override = material
	add_child(visual)

	var light := OmniLight3D.new()
	light.light_color = Color(0.20, 0.70, 1.0)
	light.light_energy = 1.5
	light.omni_range = 3.0
	add_child(light)

func _process(delta: float) -> void:
	spin += delta
	if visual != null:
		visual.rotation.y = spin * 2.0
		visual.position.y = sin(spin * 2.0) * 0.08

func _on_body_entered(body: Node) -> void:
	if collected:
		return
	if not body.has_method("collect_ultimate_orb"):
		return
	collected = true
	body.collect_ultimate_orb()
	queue_free()

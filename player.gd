extends CharacterBody3D

# ============================================================
# PLAYER
# ============================================================

const WALK_SPEED := 6.0
const SPRINT_SPEED := 9.0
const JUMP_SPEED := 5.0
const GRAVITY := 16.0
const AIR_CONTROL := 4.0
const MOUSE_SENSITIVITY := 0.0025

@onready var camera: Camera3D = $Camera3D

var pitch := 0.0


# ============================================================
# WEAPONS
# ============================================================

const WEAPON_VANDAL := 0
const WEAPON_KARAMBIT := 1

const VANDAL_DAMAGE := 30.0
const VANDAL_RANGE := 300.0
const VANDAL_FIRE_DELAY := 0.10
const VANDAL_MAG_SIZE := 25
const VANDAL_RELOAD_TIME := 1.8

const KARAMBIT_DAMAGE := 50.0
const KARAMBIT_RANGE := 3.0
const KARAMBIT_DELAY := 0.40

var current_weapon := WEAPON_VANDAL
var ammo := VANDAL_MAG_SIZE
var fire_timer := 0.0
var knife_timer := 0.0
var reload_timer := 0.0
var reloading := false


# ============================================================
# WEAPONS
# ============================================================

var weapon_holder: Node3D
var vandal: Node3D
var karambit: Node3D

var left_hand: MeshInstance3D
var right_hand: MeshInstance3D


# ============================================================
# STATS
# ============================================================

var total_damage := 0.0
var last_damage := 0.0
var kills := 0

var health := 100.0
var max_health := 100.0


# ============================================================
# AGENTS
# ============================================================

# 1 = Jett
# 2 = Reyna
# 3 = Omen

var selected_agent := 1

var ability_ready := true
var ability_cooldown := 0.0

var ult_points := 0
var ult_cost := 8

var reyna_soul_available := false
var reyna_empress_active := false


# ============================================================
# CROSSHAIR
# ============================================================

var crosshair_layer: CanvasLayer


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	create_crosshair()
	create_weapon_holder()
	create_hands()
	create_vandal()
	create_karambit()

	equip_vandal()

	if get_tree().has_meta("selected_agent"):

		set_selected_agent(
			str(
				get_tree().get_meta(
					"selected_agent"
				)
			)
		)

	else:

		update_ult_cost()


# ============================================================
# INPUT
# ============================================================

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:

		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

			rotate_y(
				-event.relative.x *
				MOUSE_SENSITIVITY
			)

			pitch -= (
				event.relative.y *
				MOUSE_SENSITIVITY
			)

			pitch = clamp(
				pitch,
				deg_to_rad(-89.0),
				deg_to_rad(89.0)
			)

			camera.rotation.x = pitch


	if event is InputEventKey:

		var key := event as InputEventKey

		if not key.pressed or key.echo:
			return

		match key.keycode:

			KEY_ESCAPE:
				toggle_mouse()

			KEY_1:
				set_selected_agent("Jett")

			KEY_2:
				set_selected_agent("Reyna")

			KEY_3:
				set_selected_agent("Omen")

			KEY_V:
				equip_vandal()

			KEY_K:
				equip_karambit()

			KEY_R:
				reload_vandal()

			KEY_C:
				use_ability_slot("C")

			KEY_Q:
				use_ability_slot("Q")

			KEY_E:
				use_ability_slot("E")

			KEY_X:
				use_ability_slot("X")


func toggle_mouse() -> void:

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	else:

		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ============================================================
# PHYSICS
# ============================================================

func _physics_process(delta: float) -> void:

	fire_timer = max(
		fire_timer - delta,
		0.0
	)

	knife_timer = max(
		knife_timer - delta,
		0.0
	)

	if reload_timer > 0.0:

		reload_timer -= delta

		if reload_timer <= 0.0:

			finish_reload()

	if ability_cooldown > 0.0:

		ability_cooldown -= delta

		if ability_cooldown <= 0.0:

			ability_ready = true

	handle_movement(delta)

	if Input.is_mouse_button_pressed(
		MOUSE_BUTTON_LEFT
	):

		if current_weapon == WEAPON_VANDAL:

			shoot_vandal()

		else:

			attack_karambit()

	move_and_slide()


# ============================================================
# NORMAL MOVEMENT
# ============================================================

func handle_movement(delta: float) -> void:

	var input_x := 0.0
	var input_z := 0.0

	if Input.is_key_pressed(KEY_A):
		input_x -= 1.0

	if Input.is_key_pressed(KEY_D):
		input_x += 1.0

	if Input.is_key_pressed(KEY_W):
		input_z -= 1.0

	if Input.is_key_pressed(KEY_S):
		input_z += 1.0

	var direction := (
		transform.basis.x * input_x
		+
		transform.basis.z * input_z
	)

	direction.y = 0.0

	if direction.length() > 1.0:

		direction = direction.normalized()

	var speed := WALK_SPEED

	if Input.is_key_pressed(KEY_SHIFT):

		speed = SPRINT_SPEED

	if is_on_floor():

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if Input.is_key_pressed(KEY_SPACE):

			velocity.y = JUMP_SPEED

	else:

		velocity.y -= GRAVITY * delta

		velocity.x = move_toward(
			velocity.x,
			direction.x * speed,
			AIR_CONTROL * delta
		)

		velocity.z = move_toward(
			velocity.z,
			direction.z * speed,
			AIR_CONTROL * delta
		)


# ============================================================
# CROSSHAIR
# ============================================================

func create_crosshair() -> void:

	crosshair_layer = CanvasLayer.new()
	crosshair_layer.name = "CrosshairLayer"

	add_child(crosshair_layer)

	var crosshair := Control.new()

	crosshair.name = "Crosshair"
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE

	crosshair_layer.add_child(crosshair)

	var viewport_size := (
		camera
		.get_viewport()
		.get_visible_rect()
		.size
	)

	crosshair.position = viewport_size * 0.5


	var top := ColorRect.new()

	top.color = Color.WHITE
	top.size = Vector2(2, 8)
	top.position = Vector2(-1, -14)

	crosshair.add_child(top)


	var bottom := ColorRect.new()

	bottom.color = Color.WHITE
	bottom.size = Vector2(2, 8)
	bottom.position = Vector2(-1, 6)

	crosshair.add_child(bottom)


	var left := ColorRect.new()

	left.color = Color.WHITE
	left.size = Vector2(8, 2)
	left.position = Vector2(-14, -1)

	crosshair.add_child(left)


	var right := ColorRect.new()

	right.color = Color.WHITE
	right.size = Vector2(8, 2)
	right.position = Vector2(6, -1)

	crosshair.add_child(right)


# ============================================================
# AIM
# ============================================================

func get_aim_ray() -> Dictionary:

	var viewport = camera.get_viewport()

	var size = viewport.get_visible_rect().size

	var center = size * 0.5

	var origin := camera.project_ray_origin(
		center
	)

	var direction := (
		camera.project_ray_normal(center)
		.normalized()
	)

	return {
		"origin": origin,
		"direction": direction
	}


func get_aim_hit(
	distance: float
) -> Dictionary:

	var ray := get_aim_ray()

	var origin: Vector3 = ray["origin"]
	var direction: Vector3 = ray["direction"]

	var end := (
		origin +
		direction * distance
	)

	var query := PhysicsRayQueryParameters3D.create(
		origin,
		end
	)

	query.exclude = [self]

	query.collide_with_bodies = true
	query.collide_with_areas = true

	var result := (
		get_world_3d()
		.direct_space_state
		.intersect_ray(query)
	)

	return {
		"origin": origin,
		"end": end,
		"result": result
	}


# ============================================================
# VANDAL
# ============================================================

func shoot_vandal() -> void:

	if reloading:
		return

	if fire_timer > 0.0:
		return

	if ammo <= 0:

		reload_vandal()

		return

	ammo -= 1

	fire_timer = VANDAL_FIRE_DELAY

	make_muzzle_flash()

	var shot := get_aim_hit(
		VANDAL_RANGE
	)

	var result: Dictionary = shot["result"]

	if result.is_empty():

		print("VANDAL MISS")

		return

	var target = result["collider"]

	print(
		"VANDAL HIT: ",
		target.name
	)

	damage_target(
		target,
		VANDAL_DAMAGE
	)


# ============================================================
# DAMAGE
# ============================================================

func damage_target(
	target: Object,
	amount: float
) -> void:

	if target == null:

		return

	var current := target as Node

	while current != null:

		if current.has_method(
			"take_damage"
		):

			current.take_damage(
				amount
			)

			total_damage += amount
			last_damage = amount

			print(
				"DAMAGE DEALT: ",
				amount
			)

			if current.has_method(
				"is_dead"
			):

				if current.is_dead():

					kills += 1

					reyna_soul_available = true

					# Kill reward.
					ult_points += 1

					clamp_ult_points()

					print(
						"KILL: ",
						kills,
						" | ULT: ",
						ult_points,
						"/",
						ult_cost
					)

			return

		current = current.get_parent()


# ============================================================
# RELOAD
# ============================================================

func reload_vandal() -> void:

	if current_weapon != WEAPON_VANDAL:
		return

	if reloading:
		return

	if ammo >= VANDAL_MAG_SIZE:
		return

	reloading = true

	reload_timer = VANDAL_RELOAD_TIME

	print(
		"RELOADING..."
	)


func finish_reload() -> void:

	ammo = VANDAL_MAG_SIZE

	reloading = false

	print(
		"VANDAL RELOADED"
	)


# ============================================================
# KARAMBIT
# ============================================================

func attack_karambit() -> void:

	if knife_timer > 0.0:
		return

	knife_timer = KARAMBIT_DELAY

	var shot := get_aim_hit(
		KARAMBIT_RANGE
	)

	var result: Dictionary = shot["result"]

	if not result.is_empty():

		damage_target(
			result["collider"],
			KARAMBIT_DAMAGE
		)


# ============================================================
# WEAPON SWITCHING
# ============================================================

func equip_vandal() -> void:

	current_weapon = WEAPON_VANDAL

	if vandal != null:

		vandal.visible = true

	if karambit != null:

		karambit.visible = false

	if left_hand != null:

		left_hand.visible = true


func equip_karambit() -> void:

	current_weapon = WEAPON_KARAMBIT

	if vandal != null:

		vandal.visible = false

	if karambit != null:

		karambit.visible = true

	if left_hand != null:

		left_hand.visible = false


# ============================================================
# AGENT SELECTION
# ============================================================

func set_selected_agent(
	agent_name: String
) -> void:

	match agent_name:

		"Jett":
			selected_agent = 1

		"Reyna":
			selected_agent = 2

		"Omen":
			selected_agent = 3

		_:
			selected_agent = 1

	update_ult_cost()

	print(
		"AGENT: ",
		get_selected_agent_name(),
		" | ULT ",
		ult_points,
		"/",
		ult_cost
	)


func get_selected_agent_name() -> String:

	match selected_agent:

		1:
			return "Jett"

		2:
			return "Reyna"

		3:
			return "Omen"

	return "Jett"


# ============================================================
# ULTIMATE SYSTEM
# ============================================================

func update_ult_cost() -> void:

	match selected_agent:

		1:
			ult_cost = 8

		2:
			ult_cost = 6

		3:
			ult_cost = 7

		_:
			ult_cost = 8

	clamp_ult_points()


func collect_ultimate_orb() -> void:

	ult_points += 1

	clamp_ult_points()

	print(
		"ULT ORB COLLECTED: ",
		ult_points,
		"/",
		ult_cost
	)


func clamp_ult_points() -> void:

	ult_points = min(
		ult_points,
		ult_cost
	)


func has_ultimate() -> bool:

	return (
		ult_points >= ult_cost
	)


func spend_ultimate() -> bool:

	if not has_ultimate():

		print(
			"ULT NOT READY: ",
			ult_points,
			"/",
			ult_cost
		)

		return false

	ult_points -= ult_cost

	print(
		"ULT USED: ",
		ult_points,
		"/",
		ult_cost
	)

	return true


# ============================================================
# ABILITY SYSTEM
# ============================================================

func use_ability_slot(
	key: String
) -> void:

	if not ability_ready:

		print(
			"ABILITY ON COOLDOWN"
		)

		return

	match selected_agent:

		1:
			use_jett_ability(key)

		2:
			use_reyna_ability(key)

		3:
			use_omen_ability(key)


func start_ability_cooldown(
	seconds: float
) -> void:

	ability_ready = false

	ability_cooldown = seconds


# ============================================================
# JETT
# ============================================================

func use_jett_ability(
	key: String
) -> void:

	match key:

		"C":
			jett_cloudburst()

		"Q":
			jett_updraft()

		"E":
			jett_tailwind()

		"X":
			jett_blade_storm()


func jett_cloudburst() -> void:

	start_ability_cooldown(
		6.0
	)

	print(
		"JETT - CLOUDBURST"
	)

	var smoke := MeshInstance3D.new()

	smoke.name = "Cloudburst"

	var mesh := SphereMesh.new()

	mesh.radius = 2.8
	mesh.height = 5.6

	smoke.mesh = mesh


	var shot := get_aim_hit(
		20.0
	)

	if not shot["result"].is_empty():

		smoke.global_position = (
			shot["result"]["position"]
		)

	else:

		smoke.global_position = (
			camera.global_position
			-
			camera.global_transform.basis.z *
			12.0
		)


	var material := StandardMaterial3D.new()

	material.transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA
	)

	material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)

	material.cull_mode = (
		BaseMaterial3D.CULL_DISABLED
	)

	material.albedo_color = Color(
		0.18,
		0.27,
		0.50,
		0.80
	)

	smoke.material_override = material


	get_tree().current_scene.add_child(
		smoke
	)


	await get_tree().create_timer(
		2.5
	).timeout


	if is_instance_valid(smoke):

		smoke.queue_free()


func jett_updraft() -> void:

	if not is_on_floor():

		return

	start_ability_cooldown(
		6.0
	)

	print(
		"JETT - UPDRAFT"
	)

	velocity.y = 10.0


func jett_tailwind() -> void:

	start_ability_cooldown(
		8.0
	)

	print(
		"JETT - TAILWIND"
	)

	var direction := (
		-transform.basis.z
	)

	direction.y = 0.0

	if direction.length() > 0.0:

		direction = direction.normalized()

	velocity = (
		direction *
		22.0
	)


func jett_blade_storm() -> void:

	if not spend_ultimate():

		return

	start_ability_cooldown(
		3.0
	)

	print(
		"JETT - BLADE STORM"
	)

	equip_karambit()


# ============================================================
# REYNA
# ============================================================

func use_reyna_ability(
	key: String
) -> void:

	match key:

		"C":
			reyna_leer()

		"Q":
			reyna_devour()

		"E":
			reyna_dismiss()

		"X":
			reyna_empress()


func reyna_leer() -> void:

	start_ability_cooldown(
		6.0
	)

	print(
		"REYNA - LEER"
	)

	var eye := MeshInstance3D.new()

	eye.name = "Leer"

	var mesh := SphereMesh.new()

	mesh.radius = 0.4
	mesh.height = 0.8

	eye.mesh = mesh


	var shot := get_aim_hit(
		10.0
	)

	if not shot["result"].is_empty():

		eye.global_position = (
			shot["result"]["position"]
		)

	else:

		eye.global_position = (
			camera.global_position
			-
			camera.global_transform.basis.z *
			8.0
		)


	var material := StandardMaterial3D.new()

	material.albedo_color = Color(
		0.65,
		0.10,
		0.90
	)

	material.emission_enabled = true

	material.emission = Color(
		0.40,
		0.02,
		0.70
	)

	material.emission_energy_multiplier = 2.0

	eye.material_override = material


	get_tree().current_scene.add_child(
		eye
	)


	await get_tree().create_timer(
		4.0
	).timeout


	if is_instance_valid(eye):

		eye.queue_free()


func reyna_devour() -> void:

	if not reyna_soul_available:

		print(
			"REYNA - NO SOUL"
		)

		return

	start_ability_cooldown(
		8.0
	)

	reyna_soul_available = false

	health = min(
		health + 50.0,
		max_health
	)

	print(
		"REYNA - DEVOUR | HP ",
		health
	)


func reyna_dismiss() -> void:

	if not reyna_soul_available:

		print(
			"REYNA - NO SOUL"
		)

		return

	start_ability_cooldown(
		8.0
	)

	reyna_soul_available = false

	print(
		"REYNA - DISMISS"
	)

	visible = false

	var old_layer := collision_layer

	collision_layer = 0


	await get_tree().create_timer(
		2.0
	).timeout


	visible = true

	collision_layer = old_layer


func reyna_empress() -> void:

	if not spend_ultimate():

		return

	start_ability_cooldown(
		3.0
	)

	reyna_empress_active = true

	print(
		"REYNA - EMPRESS"
	)

	await get_tree().create_timer(
		10.0
	).timeout

	reyna_empress_active = false


# ============================================================
# OMEN
# ============================================================

func use_omen_ability(
	key: String
) -> void:

	match key:

		"C":
			omen_shrouded_step()

		"Q":
			omen_paranoia()

		"E":
			omen_dark_cover()

		"X":
			omen_from_the_shadows()


func omen_shrouded_step() -> void:

	start_ability_cooldown(
		7.0
	)

	print(
		"OMEN - SHROUDED STEP"
	)

	var ray := get_aim_ray()

	var origin: Vector3 = ray["origin"]
	var direction: Vector3 = ray["direction"]

	var destination := (
		global_position +
		direction * 8.0
	)


	var query := PhysicsRayQueryParameters3D.create(
		origin,
		origin +
		direction * 8.0
	)

	query.exclude = [self]


	var result := (
		get_world_3d()
		.direct_space_state
		.intersect_ray(query)
	)


	if not result.is_empty():

		destination = (
			result["position"] -
			direction
		)


	destination.y = (
		global_position.y
	)

	global_position = destination


func omen_paranoia() -> void:

	start_ability_cooldown(
		8.0
	)

	print(
		"OMEN - PARANOIA"
	)


func omen_dark_cover() -> void:

	start_ability_cooldown(
		12.0
	)

	print(
		"OMEN - DARK COVER"
	)

	var smoke := MeshInstance3D.new()

	smoke.name = "DarkCover"

	var mesh := SphereMesh.new()

	mesh.radius = 3.0
	mesh.height = 6.0

	smoke.mesh = mesh


	var shot := get_aim_hit(
		20.0
	)

	if not shot["result"].is_empty():

		smoke.global_position = (
			shot["result"]["position"]
		)

	else:

		smoke.global_position = (
			global_position
			-
			transform.basis.z *
			12.0
		)


	var material := StandardMaterial3D.new()

	material.transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA
	)

	material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)

	material.albedo_color = Color(
		0.08,
		0.06,
		0.16,
		0.60
	)

	smoke.material_override = material


	get_tree().current_scene.add_child(
		smoke
	)


	await get_tree().create_timer(
		8.0
	).timeout


	if is_instance_valid(smoke):

		smoke.queue_free()


func omen_from_the_shadows() -> void:

	if not spend_ultimate():

		return

	start_ability_cooldown(
		5.0
	)

	print(
		"OMEN - FROM THE SHADOWS"
	)

	var direction := (
		-transform.basis.z
	)

	direction.y = 0.0

	if direction.length() > 0.0:

		direction = direction.normalized()

	global_position += (
		direction *
		20.0
	)


# ============================================================
# WEAPON HOLDER
# ============================================================

func create_weapon_holder() -> void:

	weapon_holder = Node3D.new()

	weapon_holder.name = "WeaponHolder"

	weapon_holder.position = Vector3(
		0.32,
		-0.28,
		-0.60
	)

	camera.add_child(
		weapon_holder
	)


# ============================================================
# HANDS
# ============================================================

func create_hands() -> void:

	var skin := StandardMaterial3D.new()

	skin.albedo_color = Color(
		0.62,
		0.38,
		0.25
	)


	left_hand = MeshInstance3D.new()

	left_hand.name = "LeftHand"

	var left_mesh := CapsuleMesh.new()

	left_mesh.radius = 0.075
	left_mesh.height = 0.38

	left_hand.mesh = left_mesh

	left_hand.position = Vector3(
		-0.18,
		-0.15,
		-0.45
	)

	left_hand.rotation_degrees = Vector3(
		-25.0,
		0.0,
		-15.0
	)

	left_hand.material_override = skin

	weapon_holder.add_child(
		left_hand
	)


	right_hand = MeshInstance3D.new()

	right_hand.name = "RightHand"

	var right_mesh := CapsuleMesh.new()

	right_mesh.radius = 0.08
	right_mesh.height = 0.40

	right_hand.mesh = right_mesh

	right_hand.position = Vector3(
		0.14,
		-0.17,
		-0.47
	)

	right_hand.rotation_degrees = Vector3(
		-25.0,
		0.0,
		10.0
	)

	right_hand.material_override = skin

	weapon_holder.add_child(
		right_hand
	)


# ============================================================
# VANDAL MODEL
# ============================================================

func create_vandal() -> void:

	vandal = Node3D.new()

	vandal.name = "Vandal"

	weapon_holder.add_child(
		vandal
	)


	var dark := StandardMaterial3D.new()

	dark.albedo_color = Color(
		0.035,
		0.04,
		0.045
	)

	dark.metallic = 0.55
	dark.roughness = 0.32


	var dark_2 := StandardMaterial3D.new()

	dark_2.albedo_color = Color(
		0.075,
		0.08,
		0.085
	)


	var black := StandardMaterial3D.new()

	black.albedo_color = Color(
		0.015,
		0.017,
		0.019
	)


	# Receiver
	var receiver := MeshInstance3D.new()

	var receiver_mesh := BoxMesh.new()

	receiver_mesh.size = Vector3(
		0.24,
		0.22,
		0.92
	)

	receiver.mesh = receiver_mesh

	receiver.position = Vector3(
		0.0,
		0.02,
		-0.05
	)

	receiver.material_override = dark

	vandal.add_child(
		receiver
	)


	# Upper
	var upper := MeshInstance3D.new()

	var upper_mesh := BoxMesh.new()

	upper_mesh.size = Vector3(
		0.23,
		0.13,
		0.90
	)

	upper.mesh = upper_mesh

	upper.position = Vector3(
		0.0,
		0.16,
		-0.05
	)

	upper.material_override = dark_2

	vandal.add_child(
		upper
	)


	# Handguard
	var handguard := MeshInstance3D.new()

	var handguard_mesh := BoxMesh.new()

	handguard_mesh.size = Vector3(
		0.21,
		0.17,
		0.78
	)

	handguard.mesh = handguard_mesh

	handguard.position = Vector3(
		0.0,
		0.02,
		-0.88
	)

	handguard.material_override = black

	vandal.add_child(
		handguard
	)


	# Carry handle
	var carry_handle := MeshInstance3D.new()

	var carry_mesh := BoxMesh.new()

	carry_mesh.size = Vector3(
		0.16,
		0.10,
		0.58
	)

	carry_handle.mesh = carry_mesh

	carry_handle.position = Vector3(
		0.0,
		0.33,
		0.02
	)

	carry_handle.material_override = dark_2

	vandal.add_child(
		carry_handle
	)


	# Barrel
	var barrel := MeshInstance3D.new()

	var barrel_mesh := CylinderMesh.new()

	barrel_mesh.top_radius = 0.027
	barrel_mesh.bottom_radius = 0.040
	barrel_mesh.height = 0.95

	barrel.mesh = barrel_mesh

	barrel.rotation_degrees.x = 90.0

	barrel.position = Vector3(
		0.0,
		0.055,
		-1.72
	)

	barrel.material_override = dark

	vandal.add_child(
		barrel
	)


	# Muzzle
	var muzzle_device := MeshInstance3D.new()

	var muzzle_mesh := CylinderMesh.new()

	muzzle_mesh.top_radius = 0.06
	muzzle_mesh.bottom_radius = 0.06
	muzzle_mesh.height = 0.24

	muzzle_device.mesh = muzzle_mesh

	muzzle_device.rotation_degrees.x = 90.0

	muzzle_device.position = Vector3(
		0.0,
		0.055,
		-2.20
	)

	muzzle_device.material_override = black

	vandal.add_child(
		muzzle_device
	)


	# Magazine
	var magazine := MeshInstance3D.new()

	var magazine_mesh := BoxMesh.new()

	magazine_mesh.size = Vector3(
		0.16,
		0.48,
		0.24
	)

	magazine.mesh = magazine_mesh

	magazine.position = Vector3(
		0.0,
		-0.30,
		0.03
	)

	magazine.rotation_degrees.x = -18.0

	magazine.material_override = black

	vandal.add_child(
		magazine
	)


	# Grip
	var grip := MeshInstance3D.new()

	var grip_mesh := BoxMesh.new()

	grip_mesh.size = Vector3(
		0.15,
		0.38,
		0.18
	)

	grip.mesh = grip_mesh

	grip.position = Vector3(
		0.0,
		-0.25,
		0.42
	)

	grip.rotation_degrees.x = -13.0

	grip.material_override = black

	vandal.add_child(
		grip
	)


	# Stock
	var stock := MeshInstance3D.new()

	var stock_mesh := BoxMesh.new()

	stock_mesh.size = Vector3(
		0.22,
		0.23,
		0.62
	)

	stock.mesh = stock_mesh

	stock.position = Vector3(
		0.0,
		0.02,
		0.92
	)

	stock.material_override = dark

	vandal.add_child(
		stock
	)


	# Muzzle marker
	var muzzle := Marker3D.new()

	muzzle.name = "Muzzle"

	muzzle.position = Vector3(
		0.0,
		0.055,
		-2.30
	)

	vandal.add_child(
		muzzle
	)


# ============================================================
# KARAMBIT MODEL
# ============================================================

func create_karambit() -> void:

	karambit = Node3D.new()

	karambit.name = "Karambit"

	weapon_holder.add_child(
		karambit
	)


	var blade_material := StandardMaterial3D.new()

	blade_material.albedo_color = Color(
		0.72,
		0.74,
		0.77
	)

	blade_material.metallic = 0.90


	var handle_material := StandardMaterial3D.new()

	handle_material.albedo_color = Color(
		0.025,
		0.025,
		0.03
	)


	var gold_material := StandardMaterial3D.new()

	gold_material.albedo_color = Color(
		0.88,
		0.62,
		0.15
	)


	var blade := MeshInstance3D.new()

	var blade_mesh := TorusMesh.new()

	blade_mesh.inner_radius = 0.15
	blade_mesh.outer_radius = 0.28

	blade.mesh = blade_mesh

	blade.scale = Vector3(
		0.8,
		0.2,
		1.1
	)

	blade.rotation_degrees.x = 90.0

	blade.position = Vector3(
		0.0,
		0.05,
		-0.25
	)

	blade.material_override = blade_material

	karambit.add_child(
		blade
	)


	var handle := MeshInstance3D.new()

	var handle_mesh := CapsuleMesh.new()

	handle_mesh.radius = 0.07
	handle_mesh.height = 0.42

	handle.mesh = handle_mesh

	handle.position = Vector3(
		0.15,
		0.0,
		0.20
	)

	handle.rotation_degrees.z = 90.0

	handle.material_override = handle_material

	karambit.add_child(
		handle
	)


	var ring := MeshInstance3D.new()

	var ring_mesh := TorusMesh.new()

	ring_mesh.inner_radius = 0.08
	ring_mesh.outer_radius = 0.13

	ring.mesh = ring_mesh

	ring.rotation_degrees.x = 90.0

	ring.position = Vector3(
		0.34,
		0.0,
		0.30
	)

	ring.material_override = gold_material

	karambit.add_child(
		ring
	)


# ============================================================
# MUZZLE FLASH
# ============================================================

func make_muzzle_flash() -> void:

	if vandal == null:
		return

	var light := OmniLight3D.new()

	light.light_energy = 4.0
	light.omni_range = 2.0

	light.position = Vector3(
		0.0,
		0.0,
		-1.1
	)

	vandal.add_child(
		light
	)

	await get_tree().create_timer(
		0.035
	).timeout

	if is_instance_valid(light):

		light.queue_free()

extends CharacterBody3D

const WALK_SPEED := 6.0
const SPRINT_SPEED := 9.0
const JUMP_SPEED := 5.0
const GRAVITY := 16.0
const MOUSE_SENSITIVITY := 0.0025

@onready var camera: Camera3D = $Camera3D

const VANDAL_DAMAGE := 30.0
const VANDAL_RANGE := 300.0
const VANDAL_FIRE_DELAY := 0.10
const VANDAL_MAG_SIZE := 25
const VANDAL_RELOAD_TIME := 1.8
const KARAMBIT_DAMAGE := 50.0
const KARAMBIT_RANGE := 3.0
const KARAMBIT_DELAY := 0.40

var weapon_holder: Node3D
var vandal: Node3D
var karambit: Node3D
var left_hand: MeshInstance3D
var right_hand: MeshInstance3D
var pitch := 0.0
var ammo := VANDAL_MAG_SIZE
var fire_timer := 0.0
var knife_timer := 0.0
var reload_timer := 0.0
var reloading := false
var knife_attacking := false
var ult_points := 0
var ult_cost := 8
var selected_agent := 1
var ability_cooldown := 0.0
var health := 100.0
var max_health := 100.0
var kills := 0
var total_damage := 0.0
var reyna_soul_available := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	create_weapon_holder()
	create_hands()
	create_vandal()
	create_karambit()
	set_selected_agent(str(get_tree().get_meta("selected_agent", "Jett")))
	equip_vandal()
	create_crosshair()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		pitch = clamp(pitch - event.relative.y * MOUSE_SENSITIVITY, deg_to_rad(-89.0), deg_to_rad(89.0))
		camera.rotation.x = pitch
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE: Input.mouse_mode = MOUSE_MODE_VISIBLE if Input.mouse_mode == MOUSE_MODE_CAPTURED else MOUSE_MODE_CAPTURED
			KEY_1: set_selected_agent("Jett")
			KEY_2: set_selected_agent("Reyna")
			KEY_3: set_selected_agent("Omen")
			KEY_V: equip_vandal()
			KEY_K: equip_karambit()
			KEY_R: reload_vandal()
			KEY_C: use_ability("C")
			KEY_Q: use_ability("Q")
			KEY_E: use_ability("E")
			KEY_X: use_ability("X")

func _physics_process(delta: float) -> void:
	fire_timer = max(fire_timer - delta, 0.0)
	knife_timer = max(knife_timer - delta, 0.0)
	ability_cooldown = max(ability_cooldown - delta, 0.0)
	if reload_timer > 0.0:
		reload_timer -= delta
		if reload_timer <= 0.0: finish_reload()
	handle_movement(delta)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if current_weapon() == 0: shoot_vandal()
		else: attack_karambit()
	move_and_slide()

func handle_movement(delta: float) -> void:
	var x := Input.get_axis("ui_left", "ui_right")
	var z := Input.get_axis("ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A): x = -1.0
	if Input.is_key_pressed(KEY_D): x = 1.0
	if Input.is_key_pressed(KEY_W): z = -1.0
	if Input.is_key_pressed(KEY_S): z = 1.0
	var direction := (transform.basis.x * x + transform.basis.z * z)
	direction.y = 0.0
	if direction.length() > 1.0: direction = direction.normalized()
	var speed := SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else WALK_SPEED
	if is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if Input.is_key_pressed(KEY_SPACE): velocity.y = JUMP_SPEED
	else:
		velocity.y -= GRAVITY * delta

func current_weapon() -> int:
	return 1 if karambit != null and karambit.visible else 0

func create_weapon_holder() -> void:
	weapon_holder = Node3D.new()
	weapon_holder.name = "WeaponHolder"
	weapon_holder.position = Vector3(0.32, -0.28, -0.60)
	camera.add_child(weapon_holder)

func create_crosshair() -> void:
	var layer := CanvasLayer.new()
	layer.name = "CrosshairLayer"
	add_child(layer)
	var crosshair := Control.new()
	crosshair.position = camera.get_viewport().get_visible_rect().size * 0.5
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(crosshair)
	for spec in [Vector4(-1,-14,2,8), Vector4(-1,6,2,8), Vector4(-14,-1,8,2), Vector4(6,-1,8,2)]:
		var bar := ColorRect.new()
		bar.color = Color.WHITE
		bar.position = Vector2(spec.x, spec.y)
		bar.size = Vector2(spec.z, spec.w)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		crosshair.add_child(bar)

func create_hands() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.62, 0.38, 0.25)
	left_hand = MeshInstance3D.new()
	var lm := CapsuleMesh.new(); lm.radius = 0.075; lm.height = 0.38
	left_hand.mesh = lm; left_hand.position = Vector3(-0.18,-0.15,-0.45); left_hand.material_override = mat
	weapon_holder.add_child(left_hand)
	right_hand = MeshInstance3D.new()
	var rm := CapsuleMesh.new(); rm.radius = 0.08; rm.height = 0.40
	right_hand.mesh = rm; right_hand.position = Vector3(0.14,-0.17,-0.47); right_hand.material_override = mat
	weapon_holder.add_child(right_hand)

func create_vandal() -> void:
	vandal = Node3D.new(); vandal.name = "Vandal"; weapon_holder.add_child(vandal)
	var mat := StandardMaterial3D.new(); mat.albedo_color = Color(0.04,0.045,0.05); mat.metallic = 0.5; mat.roughness = 0.35
	var receiver := MeshInstance3D.new(); var r := BoxMesh.new(); r.size = Vector3(0.24,0.22,0.92); receiver.mesh=r; receiver.position=Vector3(0,0.02,-0.05); receiver.material_override=mat; vandal.add_child(receiver)
	var barrel := MeshInstance3D.new(); var b := CylinderMesh.new(); b.top_radius=0.035; b.bottom_radius=0.04; b.height=1.05; barrel.mesh=b; barrel.rotation_degrees.x=90; barrel.position=Vector3(0,0.05,-1.15); barrel.material_override=mat; vandal.add_child(barrel)
	var grip := MeshInstance3D.new(); var g := BoxMesh.new(); g.size=Vector3(0.15,0.40,0.18); grip.mesh=g; grip.position=Vector3(0,-0.25,0.42); grip.rotation_degrees.x=-13; grip.material_override=mat; vandal.add_child(grip)
	var magazine := MeshInstance3D.new(); var m := BoxMesh.new(); m.size=Vector3(0.16,0.48,0.24); magazine.mesh=m; magazine.position=Vector3(0,-0.30,0.03); magazine.rotation_degrees.x=-18; magazine.material_override=mat; vandal.add_child(magazine)

func create_karambit() -> void:
	karambit = Node3D.new(); karambit.name = "Karambit"; weapon_holder.add_child(karambit)
	var blade_mat := StandardMaterial3D.new(); blade_mat.albedo_color=Color(0.75,0.78,0.82); blade_mat.metallic=0.9; blade_mat.roughness=0.15
	var handle_mat := StandardMaterial3D.new(); handle_mat.albedo_color=Color(0.025,0.03,0.035)
	var blade := MeshInstance3D.new(); var bm := BoxMesh.new(); bm.size=Vector3(0.07,0.16,0.55); blade.mesh=bm; blade.position=Vector3(0,0.02,-0.28); blade.rotation_degrees.z=-25; blade.material_override=blade_mat; karambit.add_child(blade)
	var handle := MeshInstance3D.new(); var hm := CapsuleMesh.new(); hm.radius=0.065; hm.height=0.36; handle.mesh=hm; handle.position=Vector3(0.04,-0.02,0.18); handle.rotation_degrees.z=90; handle.material_override=handle_mat; karambit.add_child(handle)
	var ring := MeshInstance3D.new(); var tm := TorusMesh.new(); tm.inner_radius=0.075; tm.outer_radius=0.12; ring.mesh=tm; ring.position=Vector3(0.04,-0.02,0.39); ring.rotation_degrees.x=90; ring.material_override=handle_mat; karambit.add_child(ring)
	karambit.position=Vector3(0.20,-0.30,-0.65)
	karambit.rotation_degrees=Vector3(-8,15,-8)

func equip_vandal() -> void:
	vandal.visible=true; karambit.visible=false; left_hand.visible=true; right_hand.visible=true

func equip_karambit() -> void:
	vandal.visible=false; karambit.visible=true; left_hand.visible=false; right_hand.visible=true

func get_aim_ray() -> Dictionary:
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	return {"origin": camera.project_ray_origin(center), "direction": camera.project_ray_normal(center).normalized()}

func get_aim_hit(distance: float) -> Dictionary:
	var ray := get_aim_ray(); var origin: Vector3 = ray.origin; var dir: Vector3 = ray.direction
	var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * distance)
	query.exclude=[self]; query.collide_with_bodies=true; query.collide_with_areas=true
	return {"result": get_world_3d().direct_space_state.intersect_ray(query)}

func shoot_vandal() -> void:
	if reloading or fire_timer > 0.0: return
	if ammo <= 0: reload_vandal(); return
	ammo -= 1; fire_timer=VANDAL_FIRE_DELAY
	var hit := get_aim_hit(VANDAL_RANGE).result
	if not hit.is_empty(): damage_target(hit.collider, VANDAL_DAMAGE)

func reload_vandal() -> void:
	if ammo >= VANDAL_MAG_SIZE or reloading: return
	reloading=true; reload_timer=VANDAL_RELOAD_TIME

func finish_reload() -> void:
	ammo=VANDAL_MAG_SIZE; reloading=false

func attack_karambit() -> void:
	if knife_attacking or knife_timer > 0.0: return
	knife_attacking=true; knife_timer=KARAMBIT_DELAY
	var start_pos := karambit.position; var start_rot := karambit.rotation_degrees
	var t := create_tween().set_parallel(true)
	t.tween_property(karambit,"position",start_pos+Vector3(0.08,-0.02,0.05),0.05)
	t.tween_property(karambit,"rotation_degrees",start_rot+Vector3(10,-10,25),0.05)
	await t.finished
	var slash := create_tween().set_parallel(true)
	slash.tween_property(karambit,"position",start_pos+Vector3(-0.20,0.10,0.10),0.08)
	slash.tween_property(karambit,"rotation_degrees",start_rot+Vector3(-30,20,-85),0.08)
	await slash.finished
	var hit := get_aim_hit(KARAMBIT_RANGE).result
	if not hit.is_empty(): damage_target(hit.collider,KARAMBIT_DAMAGE)
	var back := create_tween().set_parallel(true)
	back.tween_property(karambit,"position",start_pos,0.14)
	back.tween_property(karambit,"rotation_degrees",start_rot,0.14)
	await back.finished
	knife_attacking=false

func damage_target(target: Object, amount: float) -> void:
	if target == null: return
	var node := target as Node
	while node != null:
		if node.has_method("take_damage"):
			node.take_damage(amount); total_damage += amount
			if node.has_method("is_dead") and node.is_dead():
				kills += 1; reyna_soul_available=true; ult_points=min(ult_points+1,ult_cost)
			return
		node=node.get_parent()

func set_selected_agent(agent_name: String) -> void:
	match agent_name:
		"Jett": selected_agent=1
		"Reyna": selected_agent=2
		"Omen": selected_agent=3
		_: selected_agent=1
	match selected_agent:
		1: ult_cost=8
		2: ult_cost=6
		3: ult_cost=7
	ult_points=min(ult_points,ult_cost)

func collect_ultimate_orb() -> void:
	ult_points=min(ult_points+1,ult_cost)
	print("ULT ",ult_points,"/",ult_cost)

func spend_ultimate() -> bool:
	if ult_points < ult_cost: return false
	ult_points -= ult_cost
	return true

func use_ability(key: String) -> void:
	if ability_cooldown > 0.0: return
	match selected_agent:
		1: use_jett(key)
		2: use_reyna(key)
		3: use_omen(key)

func use_jett(key: String) -> void:
	match key:
		"C": cloudburst()
		"Q": updraft()
		"E": tailwind()
		"X":
			if spend_ultimate(): print("BLADE STORM")

func cloudburst() -> void:
	ability_cooldown=2.5
	var smoke:=MeshInstance3D.new(); var mesh:=SphereMesh.new(); mesh.radius=2.6; mesh.height=5.2; smoke.mesh=mesh
	var hit:=get_aim_hit(20.0).result
	if not hit.is_empty(): smoke.global_position=hit.position
	else: smoke.global_position=camera.global_position-camera.global_transform.basis.z*12.0
	var mat:=StandardMaterial3D.new(); mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; mat.albedo_color=Color(0.20,0.35,0.75,0.72); mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED; smoke.material_override=mat
	get_tree().current_scene.add_child(smoke)
	await get_tree().create_timer(2.5).timeout
	if is_instance_valid(smoke): smoke.queue_free()

func updraft() -> void:
	if is_on_floor(): velocity.y=10.0; ability_cooldown=6.0

func tailwind() -> void:
	ability_cooldown=8.0; velocity=-transform.basis.z*22.0

func use_reyna(key: String) -> void:
	match key:
		"C": ability_cooldown=6.0
		"Q":
			if reyna_soul_available: reyna_soul_available=false; health=min(max_health,health+50.0); ability_cooldown=8.0
		"E":
			if reyna_soul_available: reyna_soul_available=false; visible=false; collision_layer=0; await get_tree().create_timer(2.0).timeout; visible=true; collision_layer=1
		"X":
			if spend_ultimate(): ability_cooldown=10.0

func use_omen(key: String) -> void:
	match key:
		"C":
			ability_cooldown=7.0; global_position += -transform.basis.z*8.0
		"Q": ability_cooldown=8.0
		"E":
			ability_cooldown=8.0
			var smoke:=MeshInstance3D.new(); var mesh:=SphereMesh.new(); mesh.radius=3.0; mesh.height=6.0; smoke.mesh=mesh; smoke.global_position=camera.global_position-camera.global_transform.basis.z*12.0
			var mat:=StandardMaterial3D.new(); mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; mat.albedo_color=Color(0.08,0.06,0.16,0.60); smoke.material_override=mat; get_tree().current_scene.add_child(smoke)
			await get_tree().create_timer(8.0).timeout
			if is_instance_valid(smoke): smoke.queue_free()
		"X":
			if spend_ultimate(): ability_cooldown=5.0

extends Area3D

var collected := false


func _ready():

	collision_layer = 2
	collision_mask = 1

	body_entered.connect(
		_on_body_entered
	)


func _on_body_entered(body):

	if collected:
		return

	if body.has_method(
		"collect_ultimate_orb"
	):

		collected = true

		body.collect_ultimate_orb()

		queue_free()

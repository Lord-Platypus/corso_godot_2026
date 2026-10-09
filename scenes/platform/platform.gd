extends Node3D

func on_hide()-> void:
	var blocks: Array[StaticBody3D]
	blocks.assign(get_children())
	for i in blocks.size():
		(blocks[i].get_node_or_null("CUBOTERRA") as Node3D).visible = false
		(blocks[i].get_node_or_null("CollisionShape3D") as CollisionShape3D).disabled = true

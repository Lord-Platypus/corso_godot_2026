extends StaticBody3D

@export var delay : float= 0

func _ready() -> void:
	$Timer.wait_time = delay
	$Timer.start()

func on_tick() -> void:
	$CollisionShape3D.disabled = !$CollisionShape3D.disabled
	$MeshInstance3D.visible = !$MeshInstance3D.visible

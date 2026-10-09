extends Camera3D

@export var target: Node3D

func _physics_process(delta: float) -> void:
	position.x = target.position.x
	position.y = target.position.y
	

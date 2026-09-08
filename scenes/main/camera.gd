extends Camera3D

# Chi seguire. Si sceglie dall'Inspector.
@export var player: Node3D


func _process(_delta: float) -> void:
	if player:
		# Copia solo la X: altezza e profondità restano fisse.
		position.x = player.position.x
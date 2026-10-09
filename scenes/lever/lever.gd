extends Area3D

signal activate_lever
signal deactivate_lever

@export var animation_player:AnimationPlayer

var is_in_area : bool = false
var is_on : bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and is_in_area:
		is_on = !is_on
		if is_on:
			animation_player.play("LevaSkeletonAction")
			activate_lever.emit()
		else:
			animation_player.play_backwards("LevaSkeletonAction")
			deactivate_lever.emit()
		

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		is_in_area = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		is_in_area = false

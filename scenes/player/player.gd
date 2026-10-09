class_name Player extends CharacterBody3D

@export var mesh: Node3D
@export var speed: int = 5
@export var gravity_scale: float = 1.0
@export var jump_velocity: int = 8
@export var death_height: int = -15
@export var checkpoint: Marker3D

func _ready() -> void:
	print("sono vivo!")

func _physics_process(delta: float) -> void:
	print("Velocità: " + str(velocity.y))

	if not is_on_floor():
		print("sto aggiungendo la gravità")
		velocity = velocity + gravity_scale * get_gravity() * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var direction = Input.get_axis("left","right")
	velocity.x = direction * speed

	if direction > 0:
		mesh.rotation_degrees.y = 90
	elif direction < 0:
		mesh.rotation_degrees.y = -90

	velocity.z = 0
	move_and_slide()
	
	if global_position.y <= death_height:
		_die()

func _die() -> void:
	global_position = checkpoint.global_position

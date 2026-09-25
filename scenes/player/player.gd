extends CharacterBody3D

func _ready() -> void:
	print("sono vivo!")

func _physics_process(delta: float) -> void:
	print("Velocità: " + str(velocity.y))

	if not is_on_floor():
		print("sto aggiungendo la gravità")
		velocity = velocity + get_gravity() * delta

	move_and_slide()

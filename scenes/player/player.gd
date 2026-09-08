extends CharacterBody3D

# Quanto è veloce. Modificabile dall'Inspector.
@export var speed := 6.0
# Quanto è forte il salto. Modificabile dall'Inspector.
@export var jump_force := 5.0

@export var jump_sound: AudioStreamPlayer

# Dove ricomincia se cade nel vuoto.
var spawn_position: Vector3


func _ready() -> void:
	spawn_position = position


func _physics_process(delta: float) -> void:
	# Se non sto toccando terra, la gravità mi tira giù.
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			jump_sound.play()
			velocity.y = jump_force
	else:	
		velocity += get_gravity() * delta

	# Leggo le frecce: -1 sinistra, +1 destra, 0 fermo.
	var direction := Input.get_axis("left", "right")
	if direction != 0.0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

	# Questo gioco è in 2D: la profondità resta bloccata.
	velocity.z = 0.0

	# Applica il movimento e gestisci gli urti.
	move_and_slide()

	# Se sono caduto fuori dal mondo, ricomincio dall'inizio.
	if position.y < -10.0:
		position = spawn_position
		velocity = Vector3.ZERO

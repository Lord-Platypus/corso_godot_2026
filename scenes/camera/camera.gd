# Questo script è attaccato al nodo Camera3D dentro world.tscn.
# Una Camera3D è l'"occhio" del gioco: quello che vede lei è quello
# che compare sullo schermo quando premi F5.
extends Camera3D

# "target" = il bersaglio, CHI la camera deve seguire.
# Non è un numero ma un NODO 3D (": Node3D").
# Nell'Inspector della Camera3D, alla voce Target, abbiamo premuto
# "Assign..." e scelto il Player.
@export var target: Node3D

# Godot chiama questa funzione circa 60 volte al secondo.
func _physics_process(delta: float) -> void:
	# A ogni fotogramma copiamo la x (destra/sinistra) del Player
	# nella x della camera: la camera scorre di lato insieme al
	# personaggio, come in Inside o Super Mario Bros.
	position.x = target.position.x
	# NOVITÀ DELLA LEZIONE 3: copiamo anche la y (su/giù).
	# Il livello adesso ha blocchi più alti e buchi in cui cadere:
	# se la camera restasse ferma in altezza, quando salgo in cima o
	# precipito in un buco il pupazzo uscirebbe dallo schermo.
	# La profondità (z) invece resta ferma: la camera non si avvicina
	# e non si allontana mai.
	position.y = target.position.y


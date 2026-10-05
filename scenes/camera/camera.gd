# Questo script è attaccato al nodo Camera3D dentro world.tscn.
# Una Camera3D è l'"occhio" del gioco: quello che vede lei è quello
# che compare sullo schermo quando premi F5.
extends Camera3D

# "target" = il bersaglio, CHI la camera deve seguire.
# Non è un numero ma un NODO 3D (": Node3D").
# Grazie a @export compare nell'Inspector della Camera3D: alla voce
# Target abbiamo premuto "Assign..." e scelto il Player.
# Se ti dimentichi di assegnarlo, appena premi F5 compare un errore
# rosso "null instance": null = "niente", la camera cerca di seguire
# un bersaglio che non c'è.
@export var target: Node3D

# Come per il Player, Godot chiama questa funzione circa 60 volte
# al secondo. Qui non usiamo delta (per questo Godot la mostra in
# giallo): non stiamo facendo crescere niente un po' alla volta.
func _physics_process(delta: float) -> void:
	# A ogni fotogramma copiamo SOLO la x (destra/sinistra) del Player
	# nella x della camera. Altezza (y) e profondità (z) restano ferme.
	# Risultato: la camera scorre di lato insieme al personaggio, come
	# in Inside, Limbo o Super Mario Bros., e il livello può essere
	# lungo quanto vogliamo.
	# Perché non mettere semplicemente la camera FIGLIA del Player?
	# Funzionerebbe, ma quando salti salterebbe anche lei: l'immagine
	# sobbalza su e giù a ogni salto e fa venire il mal di mare.
	position.x = target.position.x

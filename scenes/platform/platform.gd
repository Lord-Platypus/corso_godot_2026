# Questo script è attaccato al nodo Platform, dentro platform.tscn.
# La piattaforma è un "pacchetto" di tre blocchi di terra (Dirt, Dirt2,
# Dirt3) messi in fila. È un PONTE che si accende e si spegne con la
# leva:
#   leva giù (accesa) -> il ponte COMPARE
#   leva su  (spenta) -> il ponte SPARISCE
#
# All'inizio del gioco il ponte NON c'è: in platform.tscn abbiamo
# spento a mano il modello e la collisione di tutti e tre i blocchi.
# Per poterlo fare abbiamo fatto clic destro su ogni blocco ->
# Editable Children ("apri la scatola"), così si vedono i suoi figli.
#
# È un Node3D semplice: non si vede e non urta niente da solo, serve
# come CONTENITORE dei suoi figli (i tre blocchi), come una cartella
# che contiene dei file.
extends Node3D

# Questa funzione NON la chiama Godot da solo.
# La chiama il campanello "deactivate_lever" della leva: in world.tscn
# abbiamo collegato quel segnale a questa funzione (Node -> Signals).
# Quindi: rialzo la leva -> la leva suona -> parte on_hide.
func on_hide()-> void:
	# --- L'ARRAY: una lista di cose ---------------------------------
	# Un Array è una LISTA: tante scatole messe in fila, ognuna con il
	# suo numero di posto. ATTENZIONE: si comincia a contare da 0.
	#   posto 0 -> Dirt
	#   posto 1 -> Dirt2
	#   posto 2 -> Dirt3
	# Esempio: l'inventario di Minecraft è un array di caselle, la
	# squadra di Pokémon è un array di 6 posti.
	#
	# "Array[StaticBody3D]" vuol dire "una lista che può contenere SOLO
	# StaticBody3D" (i nostri blocchi di terra sono StaticBody3D).
	# Per ora la lista è vuota.
	var blocks: Array[StaticBody3D]
	# get_children() = "dammi tutti i miei figli" (i tre blocchi).
	# assign() li copia dentro la nostra lista "blocks".
	blocks.assign(get_children())
	# --- IL FOR: ripeti per ogni elemento ---------------------------
	# blocks.size() = quanti elementi ci sono nella lista (qui 3).
	# "for i in 3" vuol dire: ripeti le righe qui sotto 3 volte, e ogni
	# volta metti in "i" un numero diverso: prima 0, poi 1, poi 2.
	# Così, giro dopo giro, "blocks[i]" è prima il blocco al posto 0,
	# poi quello al posto 1, poi quello al posto 2.
	# Senza for dovremmo scrivere le stesse righe tre volte, e se i
	# blocchi diventassero 50... cinquanta volte!
	for i in blocks.size():
		# Ogni blocco ha due figli:
		#   "CUBOTERRA"        = il modello 3D, quello che VEDI
		#   "CollisionShape3D" = la forma invisibile, quella che URTI
		# get_node_or_null("nome") cerca il figlio con quel nome.
		# Se non lo trova restituisce null ("niente") invece di dare
		# errore. "as Node3D" dice a Godot "trattalo come un Node3D".
		#
		# visible = false -> il modello diventa INVISIBILE.
		(blocks[i].get_node_or_null("CUBOTERRA") as Node3D).visible = false
		# disabled = true -> la collisione viene SPENTA: non si urta
		# più, ci si cade attraverso.
		# Servono tutte e due: un blocco solo invisibile è un muro
		# fantasma (ci sbatti contro ma non lo vedi); un blocco solo
		# senza collisione è un fantasma (lo vedi ma ci passi dentro).
		(blocks[i].get_node_or_null("CollisionShape3D") as CollisionShape3D).disabled = true

# Questa è la funzione GEMELLA di on_hide: fa esattamente il contrario.
# La chiama il campanello "activate_lever": abbasso la leva -> la leva
# suona -> parte on_show -> il ponte compare.
# Il codice è identico a quello sopra, cambiano solo due parole:
#   visible  = true  -> il modello torna VISIBILE
#   disabled = false -> la collisione torna ACCESA (ci si cammina sopra)
# Attenzione al doppio negativo: "disabled = false" vuol dire
# "spento = no", cioè ACCESO.
func on_show()-> void:
	var blocks: Array[StaticBody3D]
	blocks.assign(get_children())
	for i in blocks.size():
		(blocks[i].get_node_or_null("CUBOTERRA") as Node3D).visible = true
		(blocks[i].get_node_or_null("CollisionShape3D") as CollisionShape3D).disabled = false

# Tutto quello che inizia con "#" è un COMMENTO: Godot lo ignora.
# Serve solo a noi umani per ricordarci cosa fa il codice.

# --- NOVITÀ DELLA LEZIONE 3: class_name ------------------------------
# "class_name Player" dà un NOME a questo tipo di oggetto, come quando
# scrivi il nome su un'etichetta e la attacchi a una scatola.
# Da adesso in TUTTO il progetto la parola "Player" vuol dire
# "un oggetto costruito con questo script".
# Ci serve nella leva (lever.gd): lì chiediamo "chi è entrato vicino
# a me è un Player?" con la scritta "body is Player".
# Senza class_name, la parola "Player" non esisterebbe e Godot darebbe
# errore.
#
# "extends" = "estende", cioè "è un tipo di".
# Questo script è attaccato al nodo Player, che è un CharacterBody3D:
# un corpo 3D pensato per i personaggi, che si muove e urta le cose.
# Grazie a questa parola riceviamo gratis tutto quello che un
# CharacterBody3D sa già fare: la variabile "velocity" e le funzioni
# "is_on_floor()" e "move_and_slide()" che usiamo più sotto.
#
# Le due cose stanno sulla stessa riga: "si chiama Player ED è un tipo
# di CharacterBody3D".
class_name Player extends CharacterBody3D


# --- LE MANOPOLE (@export) -------------------------------------------
# "var" crea una VARIABILE: una scatola con un nome dentro cui
# teniamo un valore. Queste stanno in cima, fuori da ogni funzione:
# vivono per tutto il tempo in cui il Player esiste nel gioco.
#
# "@export" davanti a "var" trasforma la variabile in una MANOPOLA
# che compare nell'Inspector (il pannello a destra) quando selezioni
# il nodo Player. Così puoi cambiare il valore senza aprire il codice.
# Se il numero nell'Inspector è diverso da quello scritto qui,
# VINCE L'INSPECTOR.
#
# Dopo i due punti c'è il TIPO: che genere di cosa può stare nella
# scatola. Se provi a metterci la cosa sbagliata, Godot si arrabbia
# subito invece di sbagliare in silenzio.
#   int   = numero intero, senza virgola (5, 8, -15)
#   float = numero con la virgola (1.0, 0.5, 9.8)
#   Node3D, Marker3D = un NODO della scena (non un numero!)

# "mesh" non contiene un numero ma un NODO: il modello 3D del pupazzo
# di neve (SNOWMAN). Ci serve più sotto per girarlo a destra o a
# sinistra. Il modello è SOLO grafica: quello che urta il pavimento è
# la CollisionShape3D (la capsula invisibile).
@export var mesh: Node3D

# Velocità di camminata, in metri al secondo.
@export var speed: int = 5

# Moltiplicatore della gravità. 1.0 = gravità della Terra,
# 2.0 = doppia (cadi più deciso), 0.5 = metà (come sulla Luna).
@export var gravity_scale: float = 1.0

# La spinta verso l'alto quando saltiamo, in metri al secondo.
# Con 8 si sale su UN blocco (2 metri) ma non su due.
@export var jump_velocity: int = 8

# --- NOVITÀ DELLA LEZIONE 3: morire e ricomparire --------------------
# "death_height" = l'altezza della morte.
# Il pavimento è all'altezza 0. Se il Player scende sotto -15 vuol
# dire che è caduto in un buco e sta precipitando nel vuoto: è morto.
# Il numero è NEGATIVO (col meno davanti) perché è SOTTO il pavimento:
# come la temperatura sotto lo zero.
# Più è basso, più a lungo vedi il pupazzo cadere prima di ricomparire.
# È la regola di Super Mario Bros.: se cadi giù dallo schermo perdi
# una vita, non importa quanto in basso arrivi.
@export var death_height: int = -15

# "checkpoint" = il punto dove ricompari dopo essere morto.
# Non è un numero: è un nodo Marker3D, cioè un PUNTO INVISIBILE nella
# scena (nell'editor lo vedi come una piccola croce colorata).
# Nell'Inspector del Player, dentro world.tscn, alla voce Checkpoint
# abbiamo premuto "Assign..." e scelto il nodo Checkpoint.
# Esempi famosi: la panchina di Hollow Knight, il falò di Dark Souls,
# la bandierina a metà livello di Super Mario.
# Se ti dimentichi di assegnarlo, quando muori il gioco si blocca con
# un errore che parla di "Nil" (Nil = "niente", la scatola è vuota).
@export var checkpoint: Marker3D


# "func" crea una FUNZIONE: un gruppo di istruzioni con un nome.
# _ready la chiama Godot da solo, UNA volta, quando il Player entra
# in scena (cioè appena parte il gioco).
func _ready() -> void:
	# print() scrive un messaggio nel pannello Output in basso.
	# Qui va bene: succede UNA volta sola.
	print("sono vivo!")


# Questa la chiama Godot da solo circa 60 VOLTE AL SECONDO.
# Tutto quello che riguarda movimento e urti va scritto qui dentro.
# "delta" = quanti secondi sono passati dalla volta prima (circa 0.016).
#
# La frase da ricordare, vale per QUALSIASI personaggio:
#   COMANDO  ->  AGGIORNO velocity  ->  move_and_slide()
func _physics_process(delta: float) -> void:
	# Questo print scrive la velocità verticale 60 volte al secondo:
	# riempie il pannello Output di righe. Regola: i print solo nel
	# codice che gira UNA volta (come _ready). Prima o poi lo togliamo.
	print("Velocità: " + str(velocity.y))

	# --- GRAVITÀ E SALTO --------------------------------------------
	# LOGICA BINARIA: il computer ragiona solo con due risposte,
	# VERO (true) o FALSO (false), come un interruttore acceso/spento.
	# is_on_floor() è una domanda: "tocco il pavimento?" -> vero o falso.
	# "not" ROVESCIA la risposta: vero diventa falso e falso diventa vero.
	# Quindi la riga si legge: "SE NON sono sul pavimento, allora...".
	if not is_on_floor():
		# Anche questo print gira 60 volte al secondo mentre sei in aria.
		print("sto aggiungendo la gravità")
		# Sono in aria: aggiungo un po' di gravità alla velocità che
		# avevo già. A ogni fotogramma vado giù un po' più forte, cioè
		# cado ACCELERANDO come un sasso nella realtà.
		velocity = velocity + gravity_scale * get_gravity() * delta

	# "elif" = "altrimenti, se...". Si controlla SOLO se la condizione
	# sopra era FALSA, cioè se sono sul pavimento.
	# Risultato: posso saltare SOLO quando tocco terra.
	# È come dire "sono per terra E (AND) ho premuto salto".
	elif Input.is_action_just_pressed("jump"):
		# Saltare = dare una velocità verso l'ALTO (y positivo).
		# Poi ci pensa la gravità a rallentarci e riportarci giù.
		velocity.y = jump_velocity

	# --- CAMMINARE --------------------------------------------------
	# Input.get_axis("left", "right") restituisce UN SOLO numero:
	#   -1 = sto premendo sinistra
	#    1 = sto premendo destra
	#    0 = niente, oppure tutte e due insieme (si annullano)
	var direction = Input.get_axis("left","right")

	# Velocità orizzontale = direzione per velocità.
	#   -1 * 5 = -5  -> verso sinistra
	#    1 * 5 =  5  -> verso destra
	#    0 * 5 =  0  -> fermo
	velocity.x = direction * speed

	# --- GIRARE IL MODELLO ------------------------------------------
	# Giriamo solo il MODELLO (mesh), mai il Player intero.
	# 90 = guarda a destra, -90 = guarda a sinistra.
	if direction > 0:
		mesh.rotation_degrees.y = 90
	elif direction < 0:
		mesh.rotation_degrees.y = -90

	# Il mondo è 3D ma ci muoviamo su UN ASSE SOLO (destra/sinistra),
	# come in Inside o Limbo: bloccando z a zero niente può spingerci
	# "dentro" lo schermo.
	velocity.z = 0

	# move_and_slide() SPOSTA davvero il Player usando velocity, e lo
	# fa fermare o scivolare quando urta qualcosa.
	move_and_slide()

	# --- NOVITÀ DELLA LEZIONE 3: sono morto? ------------------------
	# Dopo esserci mossi facciamo una DOMANDA VERO/FALSO:
	# "la mia altezza è minore o uguale all'altezza della morte?"
	#
	# global_position = dove si trova il Player nel MONDO.
	#   .x = destra/sinistra, .y = su/giù, .z = avanti/indietro.
	#   Noi guardiamo solo .y, l'altezza.
	#
	# "<=" vuol dire "minore o uguale" (più in basso o alla stessa
	# altezza). Il risultato è VERO o FALSO, come un interruttore.
	# Esempio con death_height = -15:
	#   y =   2  -> 2 <= -15 ?   FALSO -> sono vivo, non succede niente
	#   y = -15  -> -15 <= -15 ? VERO  -> sono morto
	#   y = -20  -> -20 <= -15 ? VERO  -> sono morto
	#
	# Attenzione: questo "if" ha UN rientro (tab) solo, quindi sta
	# dentro _physics_process ma FUORI dagli if di prima: la domanda
	# viene fatta 60 volte al secondo, sempre.
	if global_position.y <= death_height:
		# Se la risposta è VERO, "premiamo il pulsante" _die.
		# Le parentesi () vogliono dire "esegui adesso questa funzione".
		_die()

# --- NOVITÀ DELLA LEZIONE 3: la funzione _die ------------------------
# Una funzione è un PULSANTE CON UN NOME: dentro ci sono delle
# istruzioni, e ogni volta che scrivi _die() quelle istruzioni partono.
# In Super Mario "perdi una vita" è una sola azione, ma la usano la
# lava, il burrone e i nemici: la scrivi una volta, la usi ovunque.
#
# Il trattino basso "_" davanti al nome è un'abitudine dei
# programmatori: vuol dire "questa funzione la usa solo il Player,
# gli altri non devono toccarla". Godot non lo controlla, è un
# promemoria per noi.
#
# Questa riga NON ha rientro: la funzione sta al margine sinistro,
# fuori da _physics_process. Se la rientri, Godot dà errore.
#
# "-> void" vuol dire "questa funzione fa una cosa ma non risponde
# niente" (void = vuoto).
func _die() -> void:
	# Spostiamo il Player nello stesso punto del Checkpoint: è come
	# un teletrasporto. Prendiamo la posizione del Checkpoint e la
	# copiamo nella posizione del Player.
	# Nota: la velocità non viene azzerata. Il pupazzo ricompare ancora
	# "lanciato" verso il basso come stava cadendo. Per farlo
	# ricomparire fermo si può aggiungere qui sotto:
	#   velocity = Vector3.ZERO
	global_position = checkpoint.global_position

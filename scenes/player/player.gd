# Tutto quello che inizia con "#" è un COMMENTO: Godot lo ignora.
# Serve solo a noi umani per ricordarci cosa fa il codice.

# "extends" = "estende", cioè "è un tipo di".
# Questo script è attaccato al nodo Player, che è un CharacterBody3D:
# un corpo 3D pensato per i personaggi, che si muove e urta le cose.
# Grazie a questa riga riceviamo gratis tutto quello che un
# CharacterBody3D sa già fare: la variabile "velocity" e le funzioni
# "is_on_floor()" e "move_and_slide()" che usiamo più sotto.
extends CharacterBody3D


# --- LE MANOPOLE (@export) -------------------------------------------
# "var" crea una VARIABILE: una scatola con un nome dentro cui
# teniamo un valore. Queste stanno in cima, fuori da ogni funzione:
# vivono per tutto il tempo in cui il Player esiste nel gioco.
#
# "@export" davanti a "var" trasforma la variabile in una MANOPOLA
# che compare nell'Inspector (il pannello a destra) quando selezioni
# il nodo Player dentro player.tscn. Così puoi cambiare il numero
# senza aprire il codice: chi disegna i livelli non deve saper
# programmare. Se il numero nell'Inspector è diverso da quello scritto
# qui, VINCE L'INSPECTOR.
#
# Dopo i due punti c'è il TIPO: che genere di cosa può stare nella
# scatola. Se provi a metterci la cosa sbagliata, Godot si arrabbia
# subito invece di sbagliare in silenzio.
#   int   = numero intero, senza virgola (5, 8, -3)
#   float = numero con la virgola (1.0, 0.5, 9.8)
#   Node3D = un NODO 3D della scena (non un numero!)

# "mesh" non contiene un numero ma un NODO: il modello 3D del pupazzo
# di neve (SNOWMAN) importato da Blender. Nell'Inspector, alla voce
# Mesh, abbiamo scelto il nodo SNOWMAN con "Assign...".
# Ci serve più sotto per girare il pupazzo a destra o a sinistra.
# Attenzione: il modello è SOLO grafica. Quello che urta il pavimento
# è la CollisionShape3D (la capsula invisibile). Il modello è un
# vestito messo sopra la capsula.
@export var mesh: Node3D

# Velocità di camminata, in metri al secondo.
# Esempi: Mario in Super Mario Bros. cammina piano e poi accelera,
# Sonic è famoso proprio per questo numero altissimo, il ragazzino
# di Inside cammina lentamente perché il gioco vuole farti guardare.
@export var speed: int = 5

# Moltiplicatore della gravità. 1.0 = gravità della Terra (9.8),
# 2.0 = doppia (cadi più deciso), 0.5 = metà (come sulla Luna).
# Lo mettiamo qui invece di cambiare la gravità di tutto il progetto
# perché così cambia SOLO per il Player, non per gli altri oggetti.
# Esempi: in Super Mario Bros. Mario cade molto più forte di come
# salirebbe nella realtà, in Celeste la caduta è rapida e precisa,
# nel livello lunare di Super Mario Odyssey si fluttua.
@export var gravity_scale: float = 1.0

# La spinta verso l'alto quando saltiamo, in metri al secondo.
# Più è grande, più si salta in alto.
# Con speed 5 e jump_velocity 8 si sale su un gradino ma non su due.
@export var jump_velocity: int = 8


# "func" crea una FUNZIONE: un gruppo di istruzioni con un nome.
# _ready la chiama Godot da solo, UNA volta, quando il Player entra
# in scena (cioè appena parte il gioco).
func _ready() -> void:
	# print() scrive un messaggio nel pannello Output in basso.
	# Qui va bene: succede UNA volta sola (un EVENTO).
	print("sono vivo!")


# Questa la chiama Godot da solo circa 60 VOLTE AL SECONDO.
# Tutto quello che riguarda movimento e urti va scritto qui dentro.
# "delta" = quanti secondi sono passati dalla volta prima (circa 0.016).
#
# La frase da ricordare, vale per QUALSIASI personaggio di QUALSIASI
# gioco (Mario, Lara Croft, il soldato di Call of Duty):
#   COMANDO  ->  AGGIORNO velocity  ->  move_and_slide()
func _physics_process(delta: float) -> void:
	# Questo print scrive la velocità verticale 60 volte al secondo:
	# in 10 secondi sono 600 righe nell'Output. Utile per guardare i
	# numeri cambiare, ma se Godot ci segnala un problema, il messaggio
	# finisce sepolto in mezzo. Regola: print sugli EVENTI, non su
	# quello che succede a ogni fotogramma.
	print("Velocità: " + str(velocity.y))

	# --- GRAVITÀ E SALTO --------------------------------------------
	# LOGICA BINARIA: il computer ragiona solo con due risposte,
	# VERO (true) o FALSO (false), come un interruttore acceso/spento.
	# is_on_floor() è una domanda: "tocco il pavimento?" -> vero o falso.
	# "not" ROVESCIA la risposta: vero diventa falso e falso diventa vero.
	# Quindi la riga si legge: "SE NON sono sul pavimento, allora...".
	if not is_on_floor():
		print("sto aggiungendo la gravità")
		# Sono in aria: aggiungo un po' di gravità alla velocità che
		# avevo già. A ogni fotogramma vado giù un po' più forte, cioè
		# cado ACCELERANDO come un sasso nella realtà.
		# gravity_scale moltiplica la gravità (vedi la manopola in cima).
		# delta serve a cadere uguale su un PC veloce e su uno lento.
		velocity = velocity + gravity_scale * get_gravity() * delta

	# "elif" = "altrimenti, se...". Si controlla SOLO se la condizione
	# sopra era FALSA, cioè se sono sul pavimento.
	# Risultato: posso saltare SOLO quando tocco terra.
	# È come scrivere "ho premuto salto AND (e) sono per terra":
	# AND è vero solo se TUTTE E DUE le cose sono vere.
	# Se togliessimo questo controllo potremmo saltare anche in aria,
	# all'infinito, come volare (Flappy Bird funziona proprio così!).
	#
	# is_action_just_pressed("jump") è vero solo nel fotogramma in cui
	# hai APPENA premuto la barra spaziatrice. Se tieni premuto, dal
	# fotogramma dopo torna falso: un salto per ogni pressione.
	# "jump" è il NOME dell'azione che abbiamo creato in
	# Project -> Project Settings -> Input Map. Il tasto (barra
	# spaziatrice) si sceglie lì, non nel codice.
	elif Input.is_action_just_pressed("jump"):
		# Saltare = dare una velocità verso l'ALTO (y positivo).
		# Poi ci pensa la gravità, fotogramma dopo fotogramma, a
		# rallentarci, fermarci in cima e riportarci giù. Nessuna
		# animazione, nessuna curva disegnata a mano: solo numeri.
		velocity.y = jump_velocity

	# --- CAMMINARE --------------------------------------------------
	# Input.get_axis("left", "right") guarda due azioni e restituisce
	# UN SOLO numero:
	#   -1 = sto premendo sinistra  (A oppure freccia sinistra)
	#    1 = sto premendo destra    (D oppure freccia destra)
	#    0 = niente, oppure tutte e due insieme (si annullano)
	# "left" e "right" sono i nomi delle azioni nell'Input Map:
	# tutto minuscolo! "Left" sarebbe un'altra azione e non ti muovi.
	# Questa "var" è DENTRO la funzione: nasce e muore 60 volte al
	# secondo, serve solo qui.
	var direction = Input.get_axis("left","right")

	# Velocità orizzontale = direzione per velocità.
	#   -1 * 5 = -5  -> verso sinistra
	#    1 * 5 =  5  -> verso destra
	#    0 * 5 =  0  -> fermo
	# Qui NON serve delta: la velocità la ASSEGNIAMO secca, non la
	# facciamo crescere un po' alla volta come la gravità.
	velocity.x = direction * speed

	# --- GIRARE IL MODELLO ------------------------------------------
	# Giriamo solo il MODELLO (mesh), mai il Player intero: la capsula
	# di collisione resta com'è.
	# rotation_degrees.y = rotazione attorno all'asse verticale, in
	# gradi. 90 = guarda a destra, -90 = guarda a sinistra.
	if direction > 0:
		mesh.rotation_degrees.y = 90
	elif direction < 0:
		mesh.rotation_degrees.y = -90
	# Se direction è 0 nessuna delle due condizioni è vera: non
	# facciamo niente e il pupazzo resta girato dove guardava.

	# --- LA RIGA DI DESIGN ------------------------------------------
	# Il mondo è 3D ma ci muoviamo su UN ASSE SOLO (destra/sinistra),
	# come in Inside, Limbo o New Super Mario Bros.: grafica 3D,
	# gioco 2D. Bloccando z a zero, niente può spingerci "dentro"
	# lo schermo, nemmeno una cassa o un urto storto.
	# È una scelta di design, non un limite tecnico: in un gioco in
	# terza persona (Fortnite, Tomb Raider) questa riga non ci sarebbe.
	velocity.z = 0

	# Fino a qui "velocity" era solo un'intenzione, dei numeri.
	# move_and_slide() SPOSTA davvero il Player usando velocity, e lo
	# fa fermare o scivolare quando urta qualcosa (pavimento, blocchi).
	# Senza questa riga non si muove niente.
	move_and_slide()

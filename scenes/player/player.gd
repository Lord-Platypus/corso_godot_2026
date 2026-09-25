# Tutto quello che inizia con "#" è un COMMENTO: Godot lo ignora.
# Serve solo a noi umani per ricordarci cosa fa il codice.

# "extends" = "estende", cioè "è un tipo di".
# Questo script è attaccato al nodo Player, che è un CharacterBody3D:
# un corpo 3D pensato per i personaggi, che si muove e urta le cose.
# Grazie a questa riga riceviamo gratis tutto quello che un
# CharacterBody3D sa già fare: la variabile "velocity" e le funzioni
# "is_on_floor()" e "move_and_slide()" che usiamo più sotto.
# Se cancelli questa riga, quei comandi smettono di esistere.
extends CharacterBody3D


# "func" crea una FUNZIONE: un gruppo di istruzioni con un nome.
# Il trattino basso all'inizio (_ready) vuol dire che non siamo noi a
# chiamarla: la chiama Godot da solo, UNA volta, quando il Player
# entra in scena (cioè appena parte il gioco).
# "-> void" vuol dire che la funzione non restituisce nessun risultato:
# fa delle cose e basta.
func _ready() -> void:
	# Le righe rientrate con il tasto Tab stanno DENTRO la funzione.
	# print() scrive un messaggio nel pannello Output in basso.
	# Il testo tra virgolette si chiama stringa (String).
	# Lo usiamo per controllare che il codice venga davvero eseguito.
	print("sono vivo!")


# Anche questa la chiama Godot da solo, ma circa 60 VOLTE AL SECONDO,
# finché il gioco è aperto. Tutto quello che riguarda movimento e
# urti va scritto qui dentro.
# "delta" è il PARAMETRO che Godot ci passa ogni volta: quanti secondi
# sono passati dalla chiamata precedente (circa 1/60 = 0.016).
# ": float" dice che delta è un numero con la virgola.
func _physics_process(delta: float) -> void:
	# "velocity" è la velocità del Player: tre numeri, uno per asse.
	#   velocity.x = destra/sinistra
	#   velocity.y = su/giù (numero negativo = verso il basso)
	#   velocity.z = avanti/indietro
	# str() trasforma il numero in testo, così possiamo attaccarlo
	# (con il +) alla stringa "Velocità: " e stamparlo.
	# Attenzione: essendo dentro _physics_process, questo messaggio
	# compare nell'Output 60 volte al secondo.
	print("Velocità: " + str(velocity.y))

	# "if" = "se". Le righe rientrate sotto l'if vengono eseguite
	# SOLO se la condizione è vera.
	# is_on_floor() è una domanda a Godot: "il Player tocca il pavimento?"
	# Risponde vero (true) o falso (false).
	# "not" rovescia la risposta: quindi l'if si legge
	# "se NON sono sul pavimento, allora...".
	if not is_on_floor():
		print("sto aggiungendo la gravità")
		# get_gravity() restituisce la gravità del mondo, che spinge
		# verso il basso. La moltiplichiamo per delta e la aggiungiamo
		# alla velocità che c'era già: così a ogni chiamata il Player
		# va giù un po' più veloce, cioè cade ACCELERANDO come nella realtà.
		# Grazie a delta cade alla stessa velocità su un PC veloce e su
		# uno lento.
		velocity = velocity + get_gravity() * delta

	# Questa riga è fuori dall'if (meno rientrata): viene eseguita sempre.
	# Fino a qui "velocity" era solo un numero, un'intenzione.
	# move_and_slide() è quella che SPOSTA davvero il Player usando
	# velocity, e lo fa fermare o scivolare quando urta qualcosa
	# (per esempio il pavimento). Senza questa riga non si muove niente.
	move_and_slide()

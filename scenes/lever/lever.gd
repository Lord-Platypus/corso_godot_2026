# Questo script è attaccato al nodo Lever (la leva), dentro lever.tscn.
#
# Un Area3D è una ZONA INVISIBILE che si accorge di chi ci entra e di
# chi ne esce. Non blocca nessuno: ci passi attraverso come attraverso
# l'aria. La forma della zona la decide il suo figlio CollisionShape3D
# (qui una sfera di 1 metro di raggio intorno alla leva).
# Esempio: la bandiera di fine livello di Super Mario, o la zona davanti
# a una porta di Zelda dove compare la scritta "Apri".
extends Area3D

# --- I SEGNALI ("il campanello") -------------------------------------
# "signal" crea un SEGNALE: un campanello che la leva può suonare.
# La leva non sa chi la sta ascoltando: suona e basta. Chi vuole
# sapere quando la leva si muove si "collega" al campanello.
# Nel nostro livello la piattaforma (Platform) è collegata al
# campanello "activate_lever": quando suona, la piattaforma sparisce.
# Il collegamento si fa nel pannello Node -> Signals, oppure si vede
# in fondo al file world.tscn.
#
# activate_lever   = "la leva è stata ABBASSATA (accesa)"
signal activate_lever
# deactivate_lever = "la leva è stata RIALZATA (spenta)"
# Per ora nessuno ascolta questo campanello: la piattaforma, una volta
# sparita, non torna più.
signal deactivate_lever

# La leva ci è arrivata dal modellatore già animata (file Leva.glb).
# L'animazione è come un piccolo video salvato dentro il modello, e
# l'AnimationPlayer è il LETTORE che lo fa partire.
# Per vederlo abbiamo fatto clic destro sul modello -> Editable Children
# ("apri la scatola"), poi nell'Inspector del Lever abbiamo assegnato
# l'AnimationPlayer a questa manopola.
@export var animation_player:AnimationPlayer

# Due variabili SENZA @export: non compaiono nell'Inspector.
# Non sono impostazioni da cambiare a mano, sono lo STATO della leva,
# cioè "come sta adesso". Tutte e due sono "bool": possono valere
# solo true (vero) o false (falso). Partono entrambe da false.
#
# is_in_area = "il Player è dentro la zona, vicino alla leva?"
var is_in_area : bool = false
# is_on = "la leva è abbassata?" Una leva è proprio un vero/falso,
# come le leve di Minecraft: o è su o è giù, non esiste "a metà".
var is_on : bool = false

# Godot chiama questa funzione circa 60 volte al secondo.
func _physics_process(delta: float) -> void:
	# --- AND: tutte e due le condizioni devono essere vere ----------
	# La leva si tira solo se HO APPENA PREMUTO E (il tasto)
	# **and** (= "e") SONO VICINO.
	#
	#   premo E    vicino    ->  tiro la leva?
	#   falso      falso         falso
	#   falso      vero          falso
	#   vero       falso         falso
	#   vero       vero          VERO
	#
	# "interact" è il nome dell'azione creata in
	# Project -> Project Settings -> Input Map, collegata al tasto E.
	# Il nome nel codice deve essere IDENTICO, maiuscole comprese.
	if Input.is_action_just_pressed("interact") and is_in_area:
		# --- NOT: "il contrario di com'era" -------------------------
		# Il punto esclamativo "!" vuol dire NOT, come la parola "not".
		# Leggiamo da destra: prendo is_on, lo rovescio, e rimetto il
		# risultato dentro is_on.
		#   era false -> diventa true  (abbasso la leva)
		#   era true  -> diventa false (rialzo la leva)
		# È l'interruttore della luce: stesso gesto, ogni volta fa il
		# contrario della volta prima.
		is_on = !is_on
		# --- IF / ELSE: se... altrimenti... -------------------------
		# SE la leva adesso è accesa...
		if is_on:
			# ...faccio partire l'animazione dall'inizio (tasto play).
			# "LevaSkeletonAction" è il nome dell'animazione dentro il
			# modello: va copiato identico dal pannello Animation.
			animation_player.play("LevaSkeletonAction")
			# ...e suono il campanello "la leva è accesa".
			# ".emit()" = "suona adesso".
			activate_lever.emit()
		# ALTRIMENTI (cioè se è spenta)...
		else:
			# ...faccio andare l'animazione al contrario (riavvolgi):
			# la leva torna su.
			animation_player.play_backwards("LevaSkeletonAction")
			# ...e suono il campanello "la leva è spenta".
			deactivate_lever.emit()


# --- CHI ENTRA, CHI ESCE ---------------------------------------------
# Queste due funzioni le ha create Godot da solo quando, nel pannello
# Node -> Signals, abbiamo fatto doppio clic su "body_entered" e
# "body_exited" (i campanelli che l'Area3D ha già di suo).
# Non le chiamiamo noi: le chiama Godot quando qualcosa entra o esce
# dalla zona. Se cambi il nome a mano, il collegamento si rompe.
#
# "body" è CHI è entrato. Può essere il Player, ma anche un blocco
# o qualsiasi altro corpo: per questo controlliamo.

# Qualcosa è ENTRATO nella zona.
func _on_body_entered(body: Node3D) -> void:
	# "is Player" = "è un Player?" -> vero o falso.
	# Funziona grazie a "class_name Player" scritto in player.gd.
	if body is Player:
		# Sì: il Player è vicino alla leva.
		is_in_area = true


# Qualcosa è USCITO dalla zona.
func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		# Il Player si è allontanato: da qui non può più tirare la leva.
		is_in_area = false

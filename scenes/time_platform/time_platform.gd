# Questo script è attaccato al nodo TimePlatform, dentro
# time_platform.tscn.
# È una piattaforma "a tempo": da sola, senza leve né pulsanti,
# compare e sparisce di continuo, come un semaforo che lampeggia.
# Il giocatore deve saltarci sopra nel momento giusto.
# Esempio: i blocchi che appaiono e scompaiono nei castelli di
# Mega Man, o le piattaforme a tempo di Super Mario.
#
# I suoi figli (li vedi nella scena time_platform.tscn):
#   CollisionShape3D = la forma invisibile, quella che URTI
#   MeshInstance3D   = la forma che VEDI (qui un semplice parallelepipedo
#                      grigio, 6 metri di lunghezza)
#   Timer            = un CRONOMETRO (vedi sotto)
#
# È uno StaticBody3D: un corpo che non si muove ma che si può urtare,
# come i blocchi di terra.
extends StaticBody3D

# --- OGNI QUANTO LAMPEGGIA ------------------------------------------
# @export = la manopola compare nell'Inspector, così ogni piattaforma
# del livello può avere il suo valore diverso.
# "delay" vuol dire "ritardo": quanti secondi passano tra un cambio e
# l'altro (c'è -> non c'è -> c'è...). È un "float", cioè un numero
# con la virgola (si scrive col punto: 1.5 = un secondo e mezzo).
#
# Dando valori diversi a piattaforme diverse, lampeggiano a velocità
# diverse: in world.tscn TimePlatform ha delay = 1 (cambia ogni
# secondo), TimePlatform2 è rimasta a 0.
# ATTENZIONE: un cronometro di 0 secondi non ha senso, quindi Godot
# rifiuta il valore 0 (scrive un errore rosso nel Debugger) e il Timer
# tiene il valore scritto in time_platform.tscn, cioè 2 secondi.
@export var delay : float= 0

# Godot chiama questa funzione UNA VOLTA SOLA, appena la piattaforma
# entra in gioco.
func _ready() -> void:
	# --- IL TIMER (il cronometro) -----------------------------------
	# Il Timer è un nodo che conta i secondi alla rovescia, come il
	# timer della cucina. Quando arriva a zero suona il suo campanello
	# "timeout" ("tempo scaduto").
	# Il segno "$" vuol dire "il mio figlio che si chiama...":
	# $Timer = il figlio di nome Timer.
	#
	# wait_time = da quanti secondi parte il conto alla rovescia.
	# Qui lo regoliamo uguale al valore scelto nell'Inspector.
	$Timer.wait_time = delay
	# start() = "parti a contare adesso".
	$Timer.start()
	# NOTA: il Timer NON è "One Shot" (colpo singolo): quando arriva a
	# zero ricomincia da capo da solo, all'infinito.

# Questa funzione NON la chiamiamo noi.
# In time_platform.tscn abbiamo collegato il campanello "timeout" del
# Timer a questa funzione (Node -> Signals). Quindi ogni volta che il
# cronometro arriva a zero, parte on_tick ("tic" dell'orologio).
func on_tick() -> void:
	# --- NOT di nuovo: "il contrario di com'era" ---------------------
	# È lo stesso trucco della leva: il "!" rovescia vero e falso.
	#   collisione spenta -> la accendo
	#   collisione accesa -> la spengo
	# Così ogni "tic" la piattaforma cambia stato: c'è, non c'è,
	# c'è, non c'è...
	$CollisionShape3D.disabled = !$CollisionShape3D.disabled
	# Stessa cosa per il modello: visibile <-> invisibile.
	# Le due righe vanno sempre insieme, altrimenti avremmo un muro
	# fantasma o un fantasma che si attraversa (vedi platform.gd).
	$MeshInstance3D.visible = !$MeshInstance3D.visible

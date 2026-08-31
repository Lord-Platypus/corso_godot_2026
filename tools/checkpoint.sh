#!/usr/bin/env bash
# =====================================================================
#  tools/checkpoint.sh
#
#  Crea un "checkpoint" del corso: uno stato congelato del progetto
#  che i partecipanti scaricano come ZIP da GitHub con un click,
#  senza sapere cos'e' git.
#
#  USO:
#      ./tools/checkpoint.sh l1-start
#
#  COSA FA, IN ORDINE:
#      0. controlla l'argomento
#      1. controlla di essere dentro un repo git
#      2. RIFIUTA di procedere se ci sono modifiche non committate
#      3. controlla che il nome non sia gia' usato
#      4. crea un branch con quel nome (partendo da dove sei ora)
#      5. crea un tag annotato con lo stesso nome
#      6. fa il push di entrambi
#      7. se 'gh' e' disponibile, pubblica la Release su /releases
#
#  PERCHE' SIA BRANCH SIA TAG:
#      - il TAG e' immutabile: e' cio' che genera lo ZIP scaricabile.
#      - il BRANCH serve a te: se scopri un errore nella lezione 3,
#        ci torni sopra, correggi e ricrei il tag, senza toccare main.
# =====================================================================

# -e  : esci subito se un comando fallisce
# -u  : errore se uso una variabile mai definita (protegge dai typo)
# -o pipefail : una pipeline fallisce se fallisce QUALSIASI suo stadio
set -euo pipefail


# --- 0. Argomento ----------------------------------------------------
# $# = numero di argomenti ricevuti. Ne vogliamo esattamente 1.
if [[ $# -ne 1 ]]; then
    echo "ERRORE: serve esattamente un argomento." >&2
    echo "Uso: $0 <nome-checkpoint>   (esempio: $0 l1-start)" >&2
    exit 1
fi

NAME="$1"

# Nomi ammessi: minuscole, cifre, punto, trattino, underscore.
# Cosi' il nome funziona come branch, come tag e dentro un URL.
if [[ ! "$NAME" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
    echo "ERRORE: '$NAME' non e' un nome valido." >&2
    echo "Usa solo minuscole, cifre, punto, trattino, underscore." >&2
    echo "Esempi buoni: l1-start  l3-fine  l6-progetto-finale" >&2
    exit 1
fi


# --- 1. Siamo dentro un repo git? ------------------------------------
# >/dev/null 2>&1 butta via sia l'output normale sia gli errori:
# a noi interessa solo se il comando riesce o no.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERRORE: questa cartella non e' un repository git." >&2
    exit 1
fi

# Spostati sulla radice del repo, cosi' lo script funziona anche se
# lo lanci da dentro una sottocartella.
cd "$(git rev-parse --show-toplevel)"


# --- 2. Il working tree e' pulito? -----------------------------------
# Questo e' il controllo richiesto: niente checkpoint a meta'.
#
# git diff-index confronta i file TRACCIATI con l'ultimo commit.
#   --quiet  -> non stampa nulla, risponde solo con l'exit code
#   HEAD     -> il commit di riferimento
#   --       -> chiude la lista dei path (evita ambiguita' con i nomi
#               di branch se un file si chiamasse come un branch)
if ! git diff-index --quiet HEAD --; then
    echo "ERRORE: ci sono modifiche non committate." >&2
    echo "Committa (o annulla) prima di creare il checkpoint:" >&2
    echo >&2
    git status --short >&2
    exit 1
fi

# diff-index NON vede i file nuovi che non sono mai stati aggiunti a
# git. Li cerco a parte, altrimenti un asset appena creato resterebbe
# fuori dal checkpoint senza che nessuno se ne accorga.
#   --others            -> file non tracciati
#   --exclude-standard  -> ...ma rispetta .gitignore (non segnala .godot/)
UNTRACKED="$(git ls-files --others --exclude-standard)"
if [[ -n "$UNTRACKED" ]]; then
    echo "ERRORE: ci sono file nuovi non ancora aggiunti a git:" >&2
    echo >&2
    echo "$UNTRACKED" >&2
    echo >&2
    echo "Aggiungili con 'git add' e committa, oppure cancellali." >&2
    exit 1
fi


# --- 3. Il nome e' gia' in uso? --------------------------------------
# Meglio fermarsi ora che scoprire a meta' push che il tag esiste.
#   --verify -> il riferimento deve essere scritto per intero
#   --quiet  -> solo exit code
if git show-ref --verify --quiet "refs/heads/$NAME"; then
    echo "ERRORE: esiste gia' un branch chiamato '$NAME'." >&2
    echo "Cancellalo con:  git branch -D $NAME" >&2
    exit 1
fi

if git show-ref --verify --quiet "refs/tags/$NAME"; then
    echo "ERRORE: esiste gia' un tag chiamato '$NAME'." >&2
    echo "Cancellalo con:   git tag -d $NAME" >&2
    echo "e sul remoto con: git push origin --delete $NAME" >&2
    exit 1
fi


# --- 4. Esiste il remoto? --------------------------------------------
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "ERRORE: nessun remoto chiamato 'origin' configurato." >&2
    exit 1
fi


# --- 5. Creazione branch e tag ---------------------------------------
COMMIT="$(git rev-parse --short HEAD)"
BRANCH_CORRENTE="$(git rev-parse --abbrev-ref HEAD)"

echo "Checkpoint  : $NAME"
echo "Dal commit  : $COMMIT (branch $BRANCH_CORRENTE)"
echo

# 'git branch NOME' crea il branch ma NON ti sposta su di esso:
# resti dove sei. E' voluto: continui a lavorare su main.
git branch "$NAME"
echo "  [ok] branch '$NAME' creato"

#   -a -> tag ANNOTATO: un oggetto vero con autore, data e messaggio.
#         GitHub lo tratta meglio di un tag "leggero".
#   -m -> il messaggio; senza, -a aprirebbe l'editor e lo script
#         resterebbe bloccato ad aspettare.
git tag -a "$NAME" -m "Checkpoint corso Godot 2026: $NAME"
echo "  [ok] tag '$NAME' creato"


# --- 6. Push ---------------------------------------------------------
# ATTENZIONE: branch e tag hanno lo STESSO nome. Scrivere
#   git push origin l1-start
# darebbe errore di ambiguita': git non saprebbe se intendi il branch
# o il tag. Per questo uso i riferimenti completi.
echo
echo "  push in corso..."
git push origin "refs/heads/$NAME" "refs/tags/$NAME"
echo "  [ok] branch e tag pubblicati su origin"


# --- 7. Release su GitHub --------------------------------------------
# Un tag da solo finisce nella pagina /tags, NON in /releases.
# Per dare ai partecipanti il pulsante di download su /releases
# serve creare una Release vera. 'gh' e' la CLI ufficiale di GitHub.
REMOTE_URL="$(git remote get-url origin)"

# Trasformo l'URL SSH in URL web:
#   ${VAR%.git}              -> toglie il suffisso .git
#   ${VAR/cerca/sostituisci} -> sostituisce la prima occorrenza
WEB_URL="${REMOTE_URL%.git}"
WEB_URL="${WEB_URL/git@github.com:/https://github.com/}"

echo
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    #   --title  -> titolo mostrato in grande sulla pagina
    #   --notes  -> corpo della release. Obbligatorio: senza, gh apre
    #               un editor e lo script si blocca.
    gh release create "$NAME" \
        --title "$NAME" \
        --notes "Punto di partenza per la lezione. Scarica 'Source code (zip)', estrai la cartella e aprila con Godot 4.7."
    echo "  [ok] release pubblicata su /releases"
else
    echo "  [!] 'gh' non disponibile o non autenticato."
    echo "      Il tag e' comunque online. Crea la release a mano qui:"
    echo "      $WEB_URL/releases/new?tag=$NAME"
fi


# --- Riepilogo -------------------------------------------------------
echo
echo "====================================================================="
echo " Checkpoint '$NAME' pronto."
echo
echo " Link da dare ai partecipanti (pagina con il pulsante di download):"
echo "   $WEB_URL/releases/tag/$NAME"
echo
echo " Link diretto allo ZIP (il download parte senza altri click):"
echo "   $WEB_URL/archive/refs/tags/$NAME.zip"
echo "====================================================================="

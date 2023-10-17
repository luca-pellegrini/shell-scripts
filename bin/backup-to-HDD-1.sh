#!/bin/bash
# backup-to-HDD-1.sh
#
# This scripts performs a backup of a set of specified directories to
# an external hard drive (labeled "HDD-1", in my personal use case).
# The set of directories, and their specific options, are hardcoded in
# the script's `sync_multimedia_dirs` and `sync_data_dirs` functions.
# Feel free to change those to suit your needs.
#
# The destination of the backup (the mount point of the external drive)
# can be specified as a parameter on the command line (defaults to
# '/media/luca/HDD-1').


date_and_time="$(date +%Y.%m.%d-%H.%M.%S)"
DEST="/media/luca/HDD-1"

if [[ -n "$XDG_CACHE_HOME" ]]; then
    log_dir="$XDG_CACHE_HOME/rsync-backups"
else
    log_dir="$HOME/.cache/rsync-backups"
fi
if [[ ! -d "$log_dir" ]]; then
    mkdir -p "$log_dir" || exit 1
fi
log_file_0="$log_dir/HDD-1-${date_and_time}.log"

## Display help message
function help_message {
    case "$LANG" in
        it_IT*|it_CH*)  # Italian translation
            echo "backup-to-HDD-1.sh
Uso: backup-to-HDD-1.sh -d <destinazione>
  o: backup-to-HDD-1.sh [opzioni]...
Fa un backup di un insieme specificato di cartelle su un drive esterno

Opzioni:
  -d, --dest <destinazione>   punto di mount del drive esterno
  -h, --help                  visualizza questo messaggio ed esce
      --version               visualizza informazioni su versione e licenza"
            ;;
        *)
            echo "backup-to-HDD-1.sh
Usage: backup-to-HDD-1.sh -d <destination>
   or: backup-to-HDD-1.sh [options]...
Backup a set of specified directories to an external drive

Options:
  -d, --dest <destination>    mount point of the external drive
  -h, --help                  display this help message and exit
      --version               display version and license information"
            ;;
    esac
}

## Display version and copying information
function version_message {
    echo "TODO: implementare la funzione 'version_message'"
}

## Print "unknown argument" message to stderr
function unknown_option {
    case "$LANG" in
        it_IT*|it_CH*)  # Italian translation
            echo "backup-to-HDD-1.sh: opzione sconosciuta '$1'" >&2
            ;;
        *)
            echo "backup-to-HDD-1.sh: unknown argument '$1'" >&2
            ;;
    esac
}

## Process command line options
while [[ -n $1 ]]; do
    case "$1" in
        -h|--help)
            help_message
            exit 0
            ;;
        --version)
            version_message
            exit 0
            ;;
        -d|--dest)
            shift
            DEST="$1"
            ;;
        *)
            unknown_option $1
            exit 1
            ;;
    esac
    shift
done

# Check if destination actually exists
if [[ -z "$DEST" || ! -d "$DEST" ]]; then
    echo "backup-to-HDD-1.sh: destinazione non specificata o non valida" >&2
    exit 1
fi

## Print header of the log file
#  The header is currently only in Italian (I'll add an English version soon)
function print_header {
    echo "### Backup con rsync ###
Data e ora di inizio:   ${date_and_time}
Utente:                 $USER
Sorgente:               $HOSTNAME
Destinazione:           $DEST"
}


function sync_multimedia_dirs {
    args="$1 -rltDvh --update --mkpath" # rsync options
    
    echo -e "\nCopia di /Data/Immagini..."
    rsync $args --exclude 'temp/' /Data/Immagini/ "$DEST/Immagini/"
    echo -e "\nCopia di /Data/Musica..."
    rsync $args --delete --exclude "temp/" /Data/Musica/ "$DEST/Musica/"
    echo -e "\nCopia di /Data/Podcast..."
    rsync $args /Data/Podcast/ "$DEST/Podcast/"
    echo -e "\nCopia di /Data/Video..."
    rsync $args --exclude 'old/' --exclude 'temp/' /Data/Video/ "$DEST/Video/"
}

function sync_data_dirs {
    args="$1 -avh --update --mkpath" # rsync options
    
    echo -e "\nCopia di ~/bin..."
    rsync $args --exclude 'MATLAB*' --exclude 'matlab*' --exclude 'tor-browser*' "$HOME/bin/" "$DEST/home/bin/"
    #echo -e "\nCopia di ~/.local/bin ..."
    #rsync -av --mkpath "$HOME/.local/bin/" "$DEST/home/.local/bin/"
    #echo -e "\nCopia di ~/.thunderbird ..."
    #rsync -av --mkpath "$HOME/.thunderbird/" "$DEST/home/.thunderbird/"
    echo -e "\nCopia di ~/config-files..."
    rsync $args --delete "$HOME/config-files/" "$DEST/home/config-files/"
    echo -e "\nCopia di /Data/Dendron..."
    rsync $args --delete /Data/Dendron/ "$DEST/Data/Dendron/"
    echo -e "\nCopia di /Data/Documenti..."
    rsync $args --exclude "Università" /Data/Documenti/ "$DEST/Data/Documenti/"
    rsync $args --delete /Data/Documenti/Università/ "$DEST/Data/Documenti/Università/"
    #echo -e "\nCopia di /Data/eseguibili..."
    #rsync $args --delete /Data/eseguibili/ "$DEST/Data/eseguibili/"
    echo -e "\nCopia di /Data/fonts..."
    rsync $args --delete /Data/fonts/ "$DEST/Data/fonts/"
    echo -e "\nCopia di /Data/Fuori_Perimetro..."
    rsync $args --delete /Data/Fuori_Perimetro/ "$DEST/Data/Fuori_Perimetro/"
    echo -e "\nCopia di /Data/Git..."
    rsync $args --delete --exclude "Altri/" --exclude "venv/" --exclude "build/" /Data/Git/ "$DEST/Data/Git/"
    echo -e "\nCopia di /Data/gufw..."
    rsync $args /Data/gufw/ "$DEST/Data/gufw/"
    echo -e "\nCopia di /Data/Libri..."
    rsync $args /Data/Libri/ "$DEST/Data/Libri/"
    echo -e "\nCopia di /Data/Programmazione..."
    rsync $args --delete --exclude "venv/" /Data/Programmazione/ "$DEST/Data/Programmazione/"
    echo -e "\nCopia di /Data/Registraz_audio..."
    rsync $args /Data/Registraz_audio/ "$DEST/Data/Registraz_audio/"
    echo -e "\nCopia di /Data/rss-feeds..."
    rsync $args /Data/rss-feeds/ "$DEST/Data/rss-feeds/"
    echo -e "\nCopia di /Data/thunderbird..."
    rsync $args /Data/thunderbird/ "$DEST/Data/thunderbird/"
    echo -e "\nCopia di /Data/Videogiochi..."
    rsync $args /Data/Videogiochi/ "$DEST/Data/Videogiochi/"
}

## DRY RUN: perform a trial run with no changes made
function dry_run {
    #sync_multimedia_dirs --dry-run
    sync_data_dirs --dry-run
}


## Ask if user wants to perform a dry run
#  The text displayed on the screen is currently only in Italian
#  (I may add an English translation in the future)
read -p "Eseguire una prova (DRY RUN) della sincronizzazione? [S/n] "

if [[ -z "$REPLY" || $REPLY == "S" || $REPLY == "s" ]]; then
    log_file_1="$log_dir/HDD-1-DRY-RUN-${date_and_time}.log"
    
    # Do a dry run and save the output to 'log_file_1'
    print_header &>> $log_file_1
    echo "###  DRY RUN  ###" &>> $log_file_1
    dry_run &>> $log_file_1
    echo "
I log della prova di sincronizzazione sono stati salvati nel file: 
${log_file_1}"
    less $log_file_1
fi

## Do the backup and save the output to 'log_file_0'
while true; do
    read -p "Eseguire la sincronizzazione ora? [s/n] "
    if [[ $REPLY == "S" || $REPLY == "s" ]]; then
        print_header &>> $log_file_0
        #sync_multimedia_dirs &>> $log_file_0
        sync_data_dirs &>> $log_file_0
        echo "
I log della sincronizzazione sono stati salvati nel file: 
${log_file_0}"
        break
    elif [[ $REPLY == "N" || $REPLY == "n" ]]; then
        break
    fi
done

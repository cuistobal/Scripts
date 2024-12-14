#!/bin/bash

# Vérifie si le dossier passé en paramètre est valide
if [ ! -d "$1" ]; then
  echo "Erreur : Le chemin '$1' n'est pas un dossier valide."
  exit 1
fi

# Dossier où les logs seront enregistrés
LOG_DIR="$1/norminette_log"

# Crée le dossier norminette_log s'il n'existe pas déjà
mkdir -p "$LOG_DIR"

# Fichier de log global
LOG_FILE="$LOG_DIR/norminette_log_all.txt"
> "$LOG_FILE"  # Vide le fichier de log existant ou le crée

# Compteur pour les fichiers de log individuels
COUNTER=0

# Fonction pour exécuter norminette dans tous les sous-dossiers
run_norminette_in_directory() {
  local dir="$1"

  # Exécution de norminette sur tous les fichiers .c dans le dossier
  for file in $(find "$dir" -type f -name "*.c"); do
    # Crée le nom du fichier de log individuel avec un compteur de 4 chiffres
    log_file="$LOG_DIR/norminette_log_$(printf "%04d" $COUNTER)"

    # Exécute norminette et redirige la sortie vers le fichier de log global
    echo "Exécution de norminette sur $file..." >> "$LOG_FILE"
    norminette "$file" >> "$LOG_FILE"

    # Incrémente le compteur
    COUNTER=$((COUNTER + 1))
  done
}

# Exécute norminette dans le dossier et ses sous-dossiers
run_norminette_in_directory "$1"

# Affiche les erreurs par fichier et nombre d'occurrences
echo "Liste des erreurs par fichier et nombre d'occurrences :"

# Compte les erreurs par fichier dans le fichier de log global
grep -hE "Error|Warning" "$LOG_FILE" | \
  awk -F: '{ key=$1 ":" $2; count[key]++ } \
    END { \
      for (f in count) { \
        print f " " count[f] " fois"; \
      } \
    }' \
  | sort


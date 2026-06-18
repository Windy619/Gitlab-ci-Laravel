#!/bin/bash
# init_server.sh — à lancer manuellement sur le serveur

BASE="$HOME/public_html/dev.exemple.com"   # adapter par env

# 1. Arborescence principale
mkdir -p "$BASE/releases"
mkdir -p "$BASE/backup"

# 2. Dossier shared (persistant entre les releases)
mkdir -p "$BASE/shared/storage/app/public"
mkdir -p "$BASE/shared/storage/framework/cache/data"
mkdir -p "$BASE/shared/storage/framework/sessions"
mkdir -p "$BASE/shared/storage/framework/views"
mkdir -p "$BASE/shared/storage/logs"

# 3. Permissions Laravel
chmod -R 775 "$BASE/shared/storage"

# 4. Fichiers à créer manuellement AVANT le 1er déploiement
touch "$BASE/shared/.env"          # ← remplir avec les vraies valeurs
touch "$BASE/shared/.htaccess"     # ← copier depuis le projet
touch "$BASE/shared/php.ini"       # ← selon tes besoins PHP

echo "Serveur prêt pour $BASE"
echo "N'oublie pas de remplir $BASE/shared/.env avant de déployer"

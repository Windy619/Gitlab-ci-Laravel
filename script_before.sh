#!/bin/bash
# ==============================================================
# init_server.sh
# Initialise la structure de déploiement Capistrano-style
# pour un environnement Laravel sur serveur cPanel/SSH.
#
# Usage :
#   bash init_server.sh <domaine>
#
# Environnements Doxo :
#   bash init_server.sh dev.mondomaine.com
#   bash init_server.sh test.mondomaine.com
#   bash init_server.sh demo.mondomaine.com
#   bash init_server.sh preprod.mondomaine.com
#   bash init_server.sh mondomaine.com
#
# À lancer UNE SEULE FOIS par environnement avant le 1er déploiement.
# ==============================================================

set -e

# --------------------------------------------------------------
# Vérification de l'argument
# --------------------------------------------------------------
if [ -z "$1" ]; then
  echo "Usage : bash init_server.sh <domaine>"
  echo "   Environnements Doxo :"
  echo "     bash init_server.sh dev-doxo.mondomaine.com"
  echo "     bash init_server.sh test-doxo.mondomaine.com"
  echo "     bash init_server.sh demo-doxo.mondomaine.com"
  echo "     bash init_server.sh preprod-doxo.mondomaine.com"
  echo "     bash init_server.sh doxo.mondomaine.com"
  exit 1
fi

DOMAIN="$1"
BASE="$HOME/public_html/$DOMAIN"

echo ""
echo "=============================================="
echo " Initialisation : $DOMAIN"
echo " Répertoire     : $BASE"
echo "=============================================="

# --------------------------------------------------------------
# 1. Arborescence principale
# --------------------------------------------------------------
echo ""
echo "Création de l'arborescence..."

mkdir -p "$BASE/releases"
mkdir -p "$BASE/backup"

echo "releases/"
echo "backup/"

# --------------------------------------------------------------
# 2. Dossier shared (persistant entre les releases)
# --------------------------------------------------------------
echo ""
echo "▶ Création du dossier shared (persistant)..."

mkdir -p "$BASE/shared/storage/app/public"
mkdir -p "$BASE/shared/storage/framework/cache/data"
mkdir -p "$BASE/shared/storage/framework/sessions"
mkdir -p "$BASE/shared/storage/framework/views"
mkdir -p "$BASE/shared/storage/logs"

echo "shared/storage/ (arborescence Laravel complète)"

# --------------------------------------------------------------
# 3. Permissions Laravel sur storage
# --------------------------------------------------------------
chmod -R 775 "$BASE/shared/storage"
echo "Permissions 775 appliquées sur shared/storage/"

# --------------------------------------------------------------
# 4. Fichiers de configuration partagés
#    (à remplir manuellement avant le 1er déploiement)
# --------------------------------------------------------------
echo ""
echo "Création des fichiers de configuration partagés..."

# .env
if [ ! -f "$BASE/shared/.env" ]; then
  cat > "$BASE/shared/.env" <<EOF
APP_NAME="Mon Application"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://$DOMAIN

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=

CACHE_DRIVER=file
QUEUE_CONNECTION=database
SESSION_DRIVER=file

MAIL_MAILER=smtp
MAIL_HOST=
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=""
MAIL_FROM_NAME="\${APP_NAME}"
EOF
  echo "shared/.env créé (à compléter !)"
else
  echo "shared/.env existe déjà, non écrasé."
fi

# .htaccess
if [ ! -f "$BASE/shared/.htaccess" ]; then
  cat > "$BASE/shared/.htaccess" <<'EOF'
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
EOF
  echo "shared/.htaccess créé (Laravel par défaut)"
else
  echo "shared/.htaccess existe déjà, non écrasé."
fi

# php.ini
if [ ! -f "$BASE/shared/php.ini" ]; then
  cat > "$BASE/shared/php.ini" <<'EOF'
; php.ini - personnalisé par environnement
max_execution_time = 120
memory_limit = 256M
upload_max_filesize = 64M
post_max_size = 64M
EOF
  echo "shared/php.ini créé"
else
  echo "shared/php.ini existe déjà, non écrasé."
fi

# --------------------------------------------------------------
# 5. Résumé
# --------------------------------------------------------------
echo ""
echo "=============================================="
echo "Initialisation terminée pour : $DOMAIN"
echo "=============================================="
echo ""
echo " Structure créée :"
echo "   $BASE/"
echo "   ├── releases/           ← releases déployées par le CI"
echo "   ├── backup/             ← 3 dernières releases sauvegardées"
echo "   ├── current → ...       ← symlink créé par le CI"
echo "   └── shared/"
echo "       ├── .env            À COMPLÉTER"
echo "       ├── .htaccess"
echo "       ├── php.ini"
echo "       └── storage/"
echo "           ├── app/public/"
echo "           ├── framework/cache/data/"
echo "           ├── framework/sessions/"
echo "           ├── framework/views/"
echo "           └── logs/"
echo ""
echo "   Actions OBLIGATOIRES avant le 1er déploiement :"
echo "   1. Remplir  : $BASE/shared/.env"
echo "   2. Vérifier : DocumentRoot Apache/Nginx → current/public"
echo "   3. Créer    : la config Supervisor pour laravel-worker-<env>"
echo ""

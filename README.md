# Gitlab-ci-Laravel
Script pour automatiser le déploiement sur les environnements de préproduction et de production avec GitLab CI/CD.

## Description du Script

> - Image Docker : Utilise l'image jakzal/phpqa:php8.1 qui inclut PHP et plusieurs outils de qualité de code.
> - Variables : Déclare des variables globales pour les chemins de déploiement, les dates, les URLs des environnements, etc.
> - Initialisation SSH : Le script d'initialisation init_ssh gère l'ajout de la clé SSH en fonction de l'environnement (production ou preproduction).
> - Stages : Définit deux stages : build et deploy.

> - Jobs :
  > - Pre-production :
  >   - Stage : deploy
  >   - Conditions : S'exécute uniquement si la branche est main.
  >   - Environnement : preproduction
  > - Scripts :
  >   - Met à jour les packages et installe openssh-client, zip, et unzip.
  >   - Initialise SSH avec la clé appropriée.
  >   - Vérifie si le dossier vendor existe, et exécute composer install ou composer update en conséquence.
  >   - Effectue les étapes de déploiement : compression du projet, transfert du fichier zip, déploiement sur le serveur de préproduction.

  > - Production :
    > - Stage : deploy
    > - Conditions : S'exécute uniquement si la branche est Production.
    > - Environnement : production
  > - Scripts :
    > - Met à jour les packages et installe openssh-client, zip, et unzip.
    > - Initialise SSH avec la clé appropriée.
    > - Vérifie si le dossier vendor existe, et exécute composer install ou composer update en conséquence.
    > - Effectue les étapes de déploiement : compression du projet, transfert du fichier zip, déploiement sur le serveur de production.

> Note : N'oubliez pas de reseigner dans gitlab les variable de connexion SSH:
  > - $SSH_PRIVATE_KEY_PROD
  > - $SSH_PRIVATE_KEY_PRE_PROD
  > - $SSH_USER_PROD
  > - $SSH_USER_PRE_PROD
  > - $SSH_HOST
  > - $SSH_PORT

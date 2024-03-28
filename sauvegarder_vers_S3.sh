#!/bin/bash

# Répertoire source local
repertoire_source="/chemin/vers/le/repertoire/local"

# Nom du bucket S3
nom_bucket_s3="nom-du-bucket"

# Répertoire dans le bucket S3 où seront copiés les fichiers
repertoire_destination_s3="repertoire/destination/sur/s3"

# Fichier contenant les informations d'identification encodées en base64 (nom_utilisateur.mot_de_passe)
fichier_authentification_base64="/chemin/vers/le/fichier/credentials_base64.txt"

# Fonction pour décoder les informations d'identification
decoder_authentification() {
    auth_encodée=$(base64 -d "$fichier_authentification_base64")
    nom_utilisateur=$(echo "$auth_encodée" | cut -d '.' -f1)
    mot_de_passe=$(echo "$auth_encodée" | cut -d '.' -f2)
}

# Fonction pour configurer l'AWS CLI
configurer_aws_cli() {
    aws configure set aws_access_key_id "$nom_utilisateur"
    aws configure set aws_secret_access_key "$mot_de_passe"
}

# Mettre à jour le fichier de log d'exécution avec les détails
mettre_a_jour_fichier_log() {
    local status
    if [ $1 -eq 0 ]; then
        status="OK"
    else
        status="KO"
    fi
    echo "$(date +"%Y-%m-%d %T") | Fichier : $2 | Statut : $status | Erreur : $3" >> "$fichier_log"
}

# Envoyer un e-mail récapitulatif
envoyer_email_recap() {
    local pour_email="$1"
    local objet="$2"
    local contenu="$3"
    
    echo "$contenu" | mail -s "$objet" "$pour_email"
}

# Fichier de log d'exécution
fichier_log="/chemin/vers/le/fichier/log_execution.txt"
touch "$fichier_log"

# Fichier de dernière exécution
fichier_derniere_execution="/chemin/vers/le/fichier/derniere_execution.txt"
touch "$fichier_derniere_execution"

# Fichier d'erreurs
fichier_erreurs="/chemin/vers/le/fichier/erreurs.txt"
touch "$fichier_erreurs"

# Début du script

# Décoder les informations d'identification
decoder_authentification

# Configurer l'AWS CLI avec les informations d'identification
configurer_aws_cli

# Récupérer la liste des fichiers modifiés depuis la dernière exécution
fichiers_modifies=$(find "$repertoire_source" -type f -newer "$fichier_derniere_execution")

# Initialiser le compteur de succès
succes=0

# Parcourir les fichiers modifiés et les copier vers S3
while read -r fichier; do
    chemin_relatif=${fichier#$repertoire_source/}
    aws s3 cp "$fichier" "s3://$nom_bucket_s3/$repertoire_destination_s3/$chemin_relatif" 2>> "$fichier_erreurs"
    if [ $? -eq 0 ]; then
        let "succes++"
        mettre_a_jour_fichier_log 0 "$fichier" ""
    else
        mettre_a_jour_fichier_log 1 "$fichier" "$(cat "$fichier_erreurs")"
    fi
done <<< "$fichiers_modifies"

# Calculer le pourcentage de succès
total=$(find "$repertoire_source" -type f -newer "$fichier_derniere_execution" | wc -l)
pourcentage_succes=$(echo "scale=2; ($succes / $total) * 100" | bc)

# Mettre à jour le fichier de dernière exécution
date +"%Y-%m-%d %T" > "$fichier_derniere_execution"

# Envoyer l'e-mail récapitulatif
objet="Copie vers S3 : $pourcentage_succes% Succès"
contenu="Récapitulatif de l'exécution du script :\n\n$(cat "$fichier_log")"
envoyer_email_recap "votre@email.com" "$objet" "$contenu"

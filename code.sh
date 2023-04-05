#!/bin/bash

# trier le contenu par date et heure
sort -k1,1 -k2,2 file.csv > sorted_file.csv

# initialiser les variables pour le regroupement
last_interval=""
type=""
nbr_OK=0
nbr_autre_resultat=0
total_value=0
count=0

# parcourir le fichier trié et regrouper les données sur une intervalle de 5mn
while read line; do
    # extraire la date et l'heure de la ligne
    date=$(echo $line | awk '{print $1}')
    heure=$(echo $line | awk '{print $2}')
    # extraire le type, le résultat et la valeur de la ligne
    current_type=$(echo $line | awk '{print $5}')
    resultat=$(echo $line | awk '{print $4}')
    valeur=$(echo $line | awk '{print $3}')
    # calculer l'intervalle de temps actuel
    current_interval=$(date -d "$date $heure" +%s)
    current_interval=$((current_interval/300))
    # si c'est la première ligne, initialiser la variable last_interval
    if [ -z "$last_interval" ]; then
        last_interval=$current_interval
    fi
    # si on a changé d'intervalle de temps, écrire les données regroupées dans le nouveau fichier
    if [ $current_interval -gt $last_interval ]; then
        # calculer la moyenne de la valeur pour l'intervalle de temps actuel
        if [ $count -gt 0 ]; then
            moyenne=$(echo "scale=2; $total_value / $count" | bc -l)
        else
            moyenne=0
        fi
        # écrire les données regroupées dans le nouveau fichier
        if [ "$type" == "P1" ]; then
            echo "$last_interval AUTRES $nbr_autre_resultat $nbr_OK $moyenne" >> output_file.csv
        else
            echo "$last_interval $type $nbr_autre_resultat $nbr_OK $moyenne" >> output_file.csv
        fi
        # réinitialiser les variables pour le nouvel intervalle de temps
        type=""
        nbr_OK=0
        nbr_autre_resultat=0
        total_value=0
        count=0
        last_interval=$current_interval
    fi
    # mettre à jour les variables pour l'intervalle de temps actuel
    if [ "$current_type" == "P1" ]; then
        if [ "$resultat" == "OK" ]; then
            nbr_OK=$((nbr_OK+1))
        else
            nbr_autre_resultat=$((nbr_autre_resultat+1))
        fi
    else
        type="AUTRES"
        nbr_autre_resultat=$((nbr_autre_resultat+1))
    fi
    total_value=$(echo "$total_value + $valeur" | bc -l)
    count=$((count+1))
done < sorted_file.csv

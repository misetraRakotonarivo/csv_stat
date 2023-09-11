#!/bin/bash

# Fonction pour calculer la somme des valeurs Success
calculate_total_success() {
  local total=0
  while read -r line; do
    if [[ $line =~ "Success" ]]; then
      local value=$(echo "$line" | awk '{print $6}')
      total=$((total + value))
    fi
  done < "$1"
  echo "$total"
}

# Fonction pour calculer la somme des valeurs Failed
calculate_total_failed() {
  local total=0
  while read -r line; do
    if [[ $line =~ "Failed" ]]; then
      local value=$(echo "$line" | awk '{print $6}')
      total=$((total + value))
    fi
  done < "$1"
  echo "$total"
}

# Appel des fonctions pour calculer les sommes
success_total=$(calculate_total_success "votre_fichier.txt")
failed_total=$(calculate_total_failed "votre_fichier.txt")

# Affichage des sommes totales
echo "Somme des valeurs Success : $success_total"
echo "Somme des valeurs Failed : $failed_total"

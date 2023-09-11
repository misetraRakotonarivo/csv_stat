# Initialisation des variables pour stocker les sommes
total_success=0
total_failed=0

# Lecture du fichier ligne par ligne
while read -r line; do
  # Vérification si la ligne contient "Success" et "Failed"
  if [[ $line =~ "Success" && $line =~ "Failed" ]]; then
    # Utilisation de 'awk' pour extraire les valeurs numériques de "Success" et "Failed"
    success_value=$(echo "$line" | awk '{print $6}')
    failed_value=$(echo "$line" | awk '{print $8}')
    
    # Ajout des valeurs à la somme totale
    total_success=$((total_success + success_value))
    total_failed=$((total_failed + failed_value))
  fi
done < votre_fichier.txt

# Affichage de la somme totale
echo "Somme des valeurs Success : $total_success"
echo "Somme des valeurs Failed : $total_failed"

# Chemin du répertoire racine
$repertoireRacine = "C:\chemin\vers\votre\repertoire"

# Chemin du fichier CSV de sortie
$csvOutputPath = "C:\chemin\vers\votre\resultat.csv"

# Exécute la recherche des fichiers XML et crée le CSV
Get-ChildItem -Path $repertoireRacine -Recurse -File -Filter *.xml | Where-Object { $_.DirectoryName -notlike "*OLDIES*" } | ForEach-Object {
    $locationValue = try {
        $xmlContent = [xml](Get-Content $_.FullName)
        $xmlContent.SelectSingleNode('//Location').InnerText
    } catch {
        Write-Host "Erreur lors de l'extraction des informations du fichier $($_.FullName): $_"
    }

    if ($locationValue -ne $null) {
        Add-Content -Path $csvOutputPath -Value "$($_.Name),$($_.DirectoryName),$locationValue"
    }
}

Write-Host "Extraction terminée. Les résultats ont été enregistrés dans $csvOutputPath"

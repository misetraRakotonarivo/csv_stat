# Chemin vers votre fichier XML
$cheminFichier = "C:\Chemin\Vers\Votre\Fichier.xml"

# Charger le contenu du fichier XML
$xmlContent = Get-Content -Path $cheminFichier -Raw

# Charger le fichier XML
$xml = [xml]$xmlContent

# Définir le namespace
$namespace = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$namespace.AddNamespace("conv", "votre_namespace_conv")

# Extraire les adresses e-mail
$emailAddresses = $xml.SelectNodes("//conv:IDPSSODescriptor/conv:ContactPerson/conv:EmailAddress/text()", $namespace) | ForEach-Object { $_.InnerText }

# Joindre les adresses e-mail séparées par des virgules
$result = $emailAddresses -join ", "

# Afficher le résultat
Write-Output $result

Clear-Host
$WShell = New-Object -com "Wscript.Shell"
while ($true) {
	$WShell.sendkeys("{SCROLLLOCK}")
	$date_time = Get-Date
	Write-Host "$date_time"
	Start-sleep -Seconds 3
}
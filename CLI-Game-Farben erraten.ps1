# Funktion für das Spiel
function Starte-Spiel {

    # Liste der Farben mit Namen, PowerShell-Farbcodes und HEX-Wert
    $farben = @(
        @{ Name = "Rot"; Farbe = "Red"; Hex = "#FF0000" },
        @{ Name = "Grün"; Farbe = "Green"; Hex = "#00FF00" },
        @{ Name = "Blau"; Farbe = "Blue"; Hex = "#0000FF" },
        @{ Name = "Gelb"; Farbe = "Yellow"; Hex = "#FFFF00" },
        @{ Name = "Magenta"; Farbe = "Magenta"; Hex = "#FF00FF" },
        @{ Name = "Cyan"; Farbe = "Cyan"; Hex = "#00FFFF" }
    )

    # Spielschleife: 10 Runden
    for ($i = 1; $i -le 10; $i++) {

        # Es wird zufällig festgelegt, ob die Farbe richtig oder falsch angezeigt werden soll
        $richtig = Get-Random -Minimum 0 -Maximum 2

        # Zufällig wird ein Farbwort ausgewählt
        $wort = Get-Random $farben

        # Eine andere/selbe Farbe als das Wort wird ausgewählt
        $andere = Get-Random ($farben | Where-Object { $_.Name -ne $wort.Name })

        $anzeigeFarbe = if ($richtig -eq 1) { $wort.Farbe } else { $andere.Farbe }

        # Farbwort wird in der ausgewählten Farbe angezeigt
        Write-Host "`n$($wort.Name)" -ForegroundColor $anzeigeFarbe

        # Stoppuhr starten, um Zeit zu messen
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $eingabe = $null  # Leere Eingabevariable

        # Spieler hat 3 Sekunden Zeit zum Reagieren
        while ($stopwatch.Elapsed.TotalSeconds -lt 3) {
            if ([System.Console]::KeyAvailable) {
                $taste = [System.Console]::ReadKey($true).Key
                $eingabe = $taste.ToString().ToUpper()
                break
            }
        }
        $stopwatch.Stop()  # Zeitmessung stoppen

        # Zeit und HEX-Code der angezeigten Farbe berechnen
        $gebrauchteZeit = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
        $anzeigeHex = ($farben | Where-Object { $_.Farbe -eq $anzeigeFarbe }).Hex

        # Auswertung der Eingabe
        if (-not $eingabe) {
            Write-Host "Zu spät! Etschi Bätsch!"
        }
        elseif (($richtig -eq 1 -and $eingabe -eq "J") -or
                ($richtig -eq 0 -and $eingabe -eq "N")) {
            Write-Host "Richtig geraten!"
        } else {
            Write-Host "Leider falsch."
        }

        # Zusatzinformationen für die Runde
        Write-Host "Angezeigte Farbe (HEX): $anzeigeHex"
        Write-Host "Du hast gebraucht: $gebrauchteZeit Sekunden"

        # Kurze Pause vor der nächsten Runde
        Start-Sleep -Seconds 2
    }
}

# Funktion für das Startmenü
function Startmenü {
    Clear-Host  # Terminal wird geleert
    Write-Host "================" -ForegroundColor Red
    Write-Host "Errate die Farbe!" -ForegroundColor Blue
    Write-Host "================" -ForegroundColor Red
    Write-Host "Hallo Spieler! Probier dich in diesem Farben erraten Spiel aus!"
    Write-Host "1. Starte das Spiel!" -ForegroundColor Magenta
    Write-Host "2. Regeln" -ForegroundColor Magenta
    Write-Host "3. Beende das Spiel" -ForegroundColor Magenta
}

# Menüschleife
do {
    Startmenü 
    $auswahl = Read-Host "Wähle eine Option aus (1-3)"  

    switch ($auswahl) {
        "1" {
            # Spiel starten
            Write-Host "Zeit das Spiel zu starten!"
            Starte-Spiel
            Pause  # Auf Tastendruck warten
        }
        "2" {
            Write-Host "`nAnleitung:" -ForegroundColor Red
            Write-Host "Die Regeln lauten wie folgt:" -ForegroundColor Blue
            Write-Host "Ziel ist es die Farben richtig zu erkennen." -ForegroundColor Blue
            Write-Host "Pro Runde darfst du 10 Mal raten, ob die Farbe mit dem Wort übereinstimmt." -ForegroundColor Blue
            Write-Host "Drücke 'J' um ja zu sagen und 'N', wenn es nicht stimmt." -ForegroundColor Blue
            Write-Host "Du hast jeweils 3 Sekunden um zu raten!" -ForegroundColor Blue
            Write-Host "Viel Glück!!!" -ForegroundColor Red
            Pause
        }
        "3" {
            Write-Host "Danke fürs Spielen. Tschüssi :)"
            break
        }
        default {
            Write-Host "Die Eingabe ist ungültig! Bitte wähle 1, 2 oder 3."
            Pause
        }
    }
} while ($auswahl -ne "3")  # Schleife endet erst bei Eingabe "3"

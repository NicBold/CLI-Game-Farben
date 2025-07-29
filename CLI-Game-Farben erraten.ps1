# Funktion für das Spiel
function Starte-Spiel {

    $anzahlRichtig = 0      ##neue Variablen hinzugefügt um Statistiken speichern zu können
    $anzahlFalsch = 0
    $reaktionszeiten = @()


    # Dictionary der Farben mit Namen, PowerShell-Farbcodes und HEX-Wert
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
            $anzahlFalsch++
        }
        elseif (($richtig -eq 1 -and $eingabe -eq "J") -or
                ($richtig -eq 0 -and $eingabe -eq "N")) {
            Write-Host "Richtig geraten!"
            $anzahlRichtig++
        }
        else {
            Write-Host "Leider falsch."
            $anzahlFalsch++
        } 

        $reaktionszeiten += $gebrauchteZeit


        # Zusatzinformationen für die Runde
        Write-Host "Angezeigte Farbe (HEX): $anzeigeHex"
        Write-Host "Du hast gebraucht: $gebrauchteZeit Sekunden"

        # Kurze Pause vor der nächsten Runde
        Start-Sleep -Seconds 2
    }

    ## Durchschnitt berechnen
    $durchschnittszeit = [math]::Round(($reaktionszeiten | Measure-Object -Average).Average, 2)
    $datum = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    ## Spielstand als Objekt
    $spielstand = [PSCustomObject]@{
        Datum = $datum
        RichtigeAntworten = $anzahlRichtig
        FalscheAntworten = $anzahlFalsch
        Durchschnittszeit = "$durchschnittszeit Sekunden"
    }

    ## Vorherige Spielstände laden (falls vorhanden)
    $dateipfad = "$PSScriptRoot\spielstaende.json"
    if (Test-Path $dateipfad) {
        $bisherige = Get-Content $dateipfad | ConvertFrom-Json

        # In Array konvertieren, falls nur ein Eintrag vorhanden ist
        if ($bisherige -isnot [System.Collections.IEnumerable]) {
            $bisherige = @($bisherige)
        }
    } else {
        $bisherige = @()
    }

    ## Neuen Spielstand anhängen
    $bisherige += $spielstand

    ## Maximal 5 Spielstände behalten
    $maxSpielstaende = 5
    if ($bisherige.Count -gt $maxSpielstaende) {
        $bisherige = $bisherige[-$maxSpielstaende..-1]
    }

    ## Zurückschreiben in JSON-Datei
    $bisherige | ConvertTo-Json -Depth 3 | Set-Content $dateipfad -Encoding UTF8

    Write-Host "`nSpielstand gespeichert unter: $dateipfad" -ForegroundColor Green
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
    Write-Host "4. Letzte Spielstände anzeigen" -ForegroundColor Magenta     ##hinzugefügt

}

# Menüschleife
do {
    Startmenü 
    $auswahl = Read-Host "Wähle eine Option aus (1-4)"  

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
        "4" {            ##hinzugefügt
            $dateipfad = "$PSScriptRoot\spielstaende.json"
            if (Test-Path $dateipfad) {
                $staende = Get-Content $dateipfad | ConvertFrom-Json

                # Falls nur ein Eintrag vorhanden ist: in Array umwandeln
                if ($staende -isnot [System.Collections.IEnumerable]) {
                    $staende = @($staende)
                }

                Write-Host "`nLetzte Spielstände:" -ForegroundColor Cyan
                $nummer = 1
                foreach ($eintrag in ($staende | Sort-Object Datum -Descending)) {
                    Write-Host "Spiel #$nummer" -ForegroundColor Yellow
                    Write-Host "Datum:             $($eintrag.Datum)"
                    Write-Host "Richtige Antworten: $($eintrag.RichtigeAntworten)"
                    Write-Host "Falsche Antworten:  $($eintrag.FalscheAntworten)"
                    Write-Host "Durchschnittszeit:  $($eintrag.Durchschnittszeit)"
                    Write-Host ""
                    $nummer++
                }
            } else {
                Write-Host "Noch keine Spielstände vorhanden." -ForegroundColor Yellow
            }
            Pause
        }


        default {
            Write-Host "Die Eingabe ist ungültig! Bitte wähle 1, 2, 3 oder 4."
            Pause
        }
    }
} while ($auswahl -ne "3")  # Schleife endet erst bei Eingabe "3"


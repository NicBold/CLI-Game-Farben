# Farbkonfiguration
function Wähle-Farbe {
    return @(
        @{ Name = "Rot"; Farbe = "Red"; Hex = "#FF0000" },
        @{ Name = "Grün"; Farbe = "Green"; Hex = "#00FF00" },
        @{ Name = "Blau"; Farbe = "Blue"; Hex = "#0000FF" },
        @{ Name = "Gelb"; Farbe = "Yellow"; Hex = "#FFFF00" },
        @{ Name = "Magenta"; Farbe = "Magenta"; Hex = "#FF00FF" },
        @{ Name = "Cyan"; Farbe = "Cyan"; Hex = "#00FFFF" }
    )
}

# Zufällige Anzeige und Entscheidung: richtig/falsch
function Zeige-Zufallsfarbe {
    param (
        $farben
    )
    $richtig = Get-Random -Minimum 0 -Maximum 2
    $wort = Get-Random $farben
    $andere = Get-Random ($farben | Where-Object { $_.Name -ne $wort.Name })
    $anzeigeFarbe = if ($richtig -eq 1) { $wort.Farbe } else { $andere.Farbe }

    Write-Host "`n$($wort.Name)" -ForegroundColor $anzeigeFarbe

    return @{
        Wort = $wort
        Farbe = $anzeigeFarbe
        Richtig = $richtig
    }
}

# Eingabe mit Zeitmessung
function Warte-auf-Eingabe {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $eingabe = $null

    while ($stopwatch.Elapsed.TotalSeconds -lt 3) {
        if ([System.Console]::KeyAvailable) {
            $taste = [System.Console]::ReadKey($true).Key
            $eingabe = $taste.ToString().ToUpper()
            break
        }
    }

    $stopwatch.Stop()
    return @{
        Eingabe = $eingabe
        Dauer = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
    }
}

# Auswertung der Eingabe
function Auswertung {
    param (
        [string]$eingabe,
        [int]$richtig
    )

    if (-not $eingabe) {
        Write-Host "Zu spät! Etschi Bätsch!"
    }
    elseif (($richtig -eq 1 -and $eingabe -eq "J") -or
            ($richtig -eq 0 -and $eingabe -eq "N")) {
        Write-Host "Richtig geraten!"
    } else {
        Write-Host "Leider falsch."
    }
}

# Spiel-Funktion (10 Runden) 
function Starte-Spiel {
    $farben = Wähle-Farbe

    for ($i = 1; $i -le 10; $i++) {
        $runde = Zeige-Zufallsfarbe -farben $farben
        $eingabeInfo = Warte-auf-Eingabe

        $anzeigeHex = ($farben | Where-Object { $_.Farbe -eq $runde.Farbe }).Hex

        Auswertung -eingabe $eingabeInfo.Eingabe -richtig $runde.Richtig

        Write-Host "Angezeigte Farbe (HEX): $anzeigeHex"
        Write-Host "Du hast gebraucht: $($eingabeInfo.Dauer) Sekunden"

        Start-Sleep -Seconds 2
    }
}

# Startmenü und Ablauf (nicht ausgelagert)
function Startmenü {
    Clear-Host
    Write-Host "================" -ForegroundColor Red
    Write-Host "Errate die Farbe!" -ForegroundColor Blue
    Write-Host "================" -ForegroundColor Red
    Write-Host "Hallo Spieler! Probier dich in diesem Farben erraten Spiel aus!"
    Write-Host "1. Starte das Spiel!" -ForegroundColor Magenta
    Write-Host "2. Regeln" -ForegroundColor Magenta
    Write-Host "3. Beende das Spiel" -ForegroundColor Magenta
}

do {
    Startmenü
    $auswahl = Read-Host "Wähle eine Option aus (1-3)"

    switch ($auswahl) {
        "1" {
            Write-Host "Zeit das Spiel zu starten!"
            Starte-Spiel
            Pause
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
} while ($auswahl -ne "3")

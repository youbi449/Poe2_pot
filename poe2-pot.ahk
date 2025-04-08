#NoEnv  ; Recommandé pour les performances et la compatibilité
#SingleInstance force  ; Remplace l'instance précédente du script
SendMode Input  ; Recommandé pour les nouveaux scripts
SetWorkingDir %A_ScriptDir%  ; Garantit la cohérence du répertoire de travail
SetTitleMatchMode, 2  ; Mode de correspondance pour les titres de fenêtres (2 = contient)

; Variables de configuration
; -- Configuration pour le mana (potion)
manaPosX := 1774  ; Position X du pixel à surveiller pour le mana
manaPosY := 966   ; Position Y du pixel à surveiller pour le mana
manaCouleurPlein := "0x225992"  ; Couleur quand le mana est plein
manaTouche := "2"  ; Touche à envoyer pour la potion de mana

; -- Configuration pour la vie (potion)
viePosX := 148  ; Position X du pixel à surveiller pour la vie
viePosY := 943   ; Position Y du pixel à surveiller pour la vie
vieCouleurPlein := "0x7C1D221"  ; Couleur quand la vie est pleine
vieTouche := "1"  ; Touche à envoyer pour la potion de vie

; -- Configuration générale
delaiVerification := 100  ; Délai entre les vérifications en millisecondes
logFichier := "poe2-logs.txt"  ; Fichier de log simplifié sans chemin absolu
surveillanceActive := false  ; État initial de la surveillance

; Initialiser le fichier de log avec un en-tête simple
FileDelete, %logFichier%  ; Supprimer l'ancien fichier de log au démarrage

; Fonction pour écrire dans le fichier log - simple et sans Try/Catch
EcrireLog(message, afficherTooltip := true) {
    global logFichier
    FormatTime, tempsActuel,, yyyy-MM-dd HH:mm:ss
    FileAppend, %tempsActuel% - %message%`n, %logFichier%
    
    ; Afficher le message dans un tooltip seulement si demandé
    if (afficherTooltip) {
        ToolTip, %message%, 100, 100
        SetTimer, EnleverToolTip, -1000  ; Le tooltip disparaît après 1 seconde
    }
}

EnleverToolTip:
    ToolTip
return

; Ajouter une entrée initiale au démarrage du script
EcrireLog("=== DÉMARRAGE DU SCRIPT POE2-POTS (LOGIQUE INVERSÉE) ===")
EcrireLog("Configuration Mana: Position X=" . manaPosX . " Y=" . manaPosY . ", Couleur plein=" . manaCouleurPlein . ", Touche=" . manaTouche)
EcrireLog("Configuration Vie: Position X=" . viePosX . " Y=" . viePosY . ", Couleur plein=" . vieCouleurPlein . ", Touche=" . vieTouche)
EcrireLog("LOGIQUE: Déclencher quand la couleur n'est PAS celle du mana/vie plein")

MsgBox, Script POE2-POTS démarré (LOGIQUE INVERSÉE). Appuyez sur F1 pour activer/désactiver la surveillance. F2 pour tester la position du curseur. F3 pour tester les pixels configurés.

; Activer ou désactiver la surveillance avec F1
F1::
    surveillanceActive := !surveillanceActive
    if (surveillanceActive) {
        SetTimer, VerifierPixels, %delaiVerification%
        ToolTip, ACTIF, 0, 0
        Sleep, 1000
        ToolTip
        EcrireLog("Surveillance POE2 ACTIVÉE", false)
    } else {
        SetTimer, VerifierPixels, Off
        ToolTip, INACTIF, 0, 0
        Sleep, 1000
        ToolTip
        EcrireLog("Surveillance POE2 DÉSACTIVÉE", false)
    }
return

; Fonction de test avec F2 pour vérifier le pixel actuellement sous le curseur
F2::
    MouseGetPos, testX, testY
    PixelGetColor, testCouleur, %testX%, %testY%, RGB
    message := "TEST: Position X=" . testX . " Y=" . testY . ", Couleur=" . testCouleur
    EcrireLog(message)
    MsgBox, %message%
return

; Fonction de test avec F3 pour vérifier spécifiquement les pixels configurés
F3::
    PixelGetColor, testCouleurMana, %manaPosX%, %manaPosY%, RGB
    PixelGetColor, testCouleurVie, %viePosX%, %viePosY%, RGB
    
    message := "TEST PIXELS CIBLES:`n"
    message .= "MANA: X=" . manaPosX . " Y=" . manaPosY . ", Couleur actuelle=" . testCouleurMana . "`n"
    message .= "  Couleur mana plein=" . manaCouleurPlein . "`n"
    message .= "  État: " . (testCouleurMana = manaCouleurPlein ? "MANA PLEIN" : "MANA NON PLEIN (potion nécessaire)") . "`n`n"
    
    message .= "VIE: X=" . viePosX . " Y=" . viePosY . ", Couleur actuelle=" . testCouleurVie . "`n"
    message .= "  Couleur vie pleine=" . vieCouleurPlein . "`n"
    message .= "  État: " . (testCouleurVie = vieCouleurPlein ? "VIE PLEINE" : "VIE NON PLEINE (potion nécessaire)")
    
    EcrireLog(message)
    MsgBox, %message%
return

; Variables pour le suivi des actions
derniereManaAction := 0
derniereVieAction := 0

; Fonction qui vérifie les pixels et appuie sur les touches correspondantes si les couleurs NE correspondent PAS
VerifierPixels:
    ; Vérifier que Path of Exile 2 est la fenêtre active
    IfWinActive, Path of Exile 2
    {
        ; --- Vérification du MANA ---
        PixelGetColor, couleurActuelleMana, %manaPosX%, %manaPosY%, RGB
        if (couleurActuelleMana != manaCouleurPlein) {
            Send, %manaTouche%
            
            ; Log seulement si c'est la première action depuis un certain temps
            tempsActuel := A_TickCount
            if (tempsActuel - derniereManaAction > 2000) {
                EcrireLog("ACTION MANA: Potion utilisée", false)
                derniereManaAction := tempsActuel
            }
            
            Sleep, 150  ; Petit délai pour éviter de spammer la touche
        }
        
        ; --- Vérification de la VIE ---
        PixelGetColor, couleurActuelleVie, %viePosX%, %viePosY%, RGB
        if (couleurActuelleVie != vieCouleurPlein) {
            Send, %vieTouche%
            
            ; Log seulement si c'est la première action depuis un certain temps
            tempsActuel := A_TickCount
            if (tempsActuel - derniereVieAction > 2000) {
                EcrireLog("ACTION VIE: Potion utilisée", false)
                derniereVieAction := tempsActuel
            }
            
            Sleep, 150  ; Petit délai pour éviter de spammer la touche
        }
        
        ; Pas de logs systématiques pour chaque vérification
    } else {
        ; Log périodique pour indiquer que le jeu n'est pas actif
        Random, rnd, 1, 500  ; Réduit encore plus la fréquence des logs
        if (rnd = 1) {
            WinGetActiveTitle, titre
            EcrireLog("INFO: Fenêtre Path of Exile 2 non active.", false)
        }
    }
return 
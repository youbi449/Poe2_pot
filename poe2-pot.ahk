#NoEnv  ; Recommandé pour les performances et la compatibilité
#SingleInstance force  ; Remplace l'instance précédente du script
SendMode Input  ; Recommandé pour les nouveaux scripts
SetWorkingDir %A_ScriptDir%  ; Garantit la cohérence du répertoire de travail
SetTitleMatchMode, 2  ; Mode de correspondance pour les titres de fenêtres (2 = contient)

; Variables de configuration
; -- Configuration pour le mana (potion)
manaPosX := 1774  ; Position X du pixel à surveiller pour le mana
manaPosY := 966   ; Position Y du pixel à surveiller pour le mana
manaCouleurPlein := 0x225992  ; Couleur quand le mana est plein (IMPORTANT: sans guillemets)
manaTouche := "2"  ; Touche à envoyer pour la potion de mana

; -- Configuration pour la vie (potion)
viePosX := 148  ; Position X du pixel à surveiller pour la vie
viePosY := 943   ; Position Y du pixel à surveiller pour la vie
vieCouleurPlein := 0x7C1D21  ; Couleur quand la vie est pleine (IMPORTANT: sans guillemets)
vieTouche := "1"  ; Touche à envoyer pour la potion de vie

; -- Configuration générale
delaiVerification := 100  ; Délai entre les vérifications en millisecondes
delaiReutilisationPotion := 2000  ; Délai minimal entre deux utilisations de potion (en ms)
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
EcrireLog("Configuration Mana: Position X=" . manaPosX . " Y=" . manaPosY . ", Couleur plein=" . Format("0x{:06X}", manaCouleurPlein) . ", Touche=" . manaTouche)
EcrireLog("Configuration Vie: Position X=" . viePosX . " Y=" . viePosY . ", Couleur plein=" . Format("0x{:06X}", vieCouleurPlein) . ", Touche=" . vieTouche)
EcrireLog("Configuration Délai: Entre deux utilisations de potion = " . delaiReutilisationPotion . "ms")
EcrireLog("LOGIQUE: Déclencher quand la couleur n'est PAS celle du mana/vie plein")

MsgBox, Script POE2-POTS démarré (LOGIQUE INVERSÉE). Appuyez sur F1 pour activer/désactiver la surveillance. F2 pour tester la position du curseur. F3 pour tester les pixels configurés. F4 pour configurer le délai entre potions. F5 pour recalibrer les couleurs. F6 pour tester les potions sans vérifier les couleurs. F7 pour tester les touches manuellement.

; Activer ou désactiver la surveillance avec F1
F1::
    surveillanceActive := !surveillanceActive
    if (surveillanceActive) {
        ; Réinitialiser les variables de délai pour éviter des problèmes au démarrage
        derniereManaAction := 0
        derniereVieAction := 0
        
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
    message .= "  Couleur mana plein=" . Format("0x{:06X}", manaCouleurPlein) . "`n"
    message .= "  État: " . ((testCouleurMana = manaCouleurPlein) ? "MANA PLEIN" : "MANA NON PLEIN (potion nécessaire)") . "`n`n"
    
    message .= "VIE: X=" . viePosX . " Y=" . viePosY . ", Couleur actuelle=" . testCouleurVie . "`n"
    message .= "  Couleur vie pleine=" . Format("0x{:06X}", vieCouleurPlein) . "`n"
    message .= "  État: " . ((testCouleurVie = vieCouleurPlein) ? "VIE PLEINE" : "VIE NON PLEINE (potion nécessaire)")
    
    EcrireLog(message)
    MsgBox, %message%
return

; Fonction pour configurer le délai de réutilisation des potions
F4::
    InputBox, nouveauDelai, Configuration Délai, Entrez le délai minimal entre deux utilisations de potion (en millisecondes):, , 300, 150, , , , , %delaiReutilisationPotion%
    if (!ErrorLevel) {  ; Si l'utilisateur n'a pas annulé
        if nouveauDelai is integer
        {
            delaiReutilisationPotion := nouveauDelai
            EcrireLog("Configuration mise à jour: Délai entre potions = " . delaiReutilisationPotion . "ms")
            MsgBox, Délai entre potions configuré à %delaiReutilisationPotion% ms
        }
        else
        {
            MsgBox, Erreur: Veuillez entrer un nombre entier valide.
        }
    }
return

; Variables pour le suivi des actions
derniereManaAction := 0
derniereVieAction := 0

; Fonction qui vérifie les pixels et appuie sur les touches correspondantes si les couleurs NE correspondent PAS
VerifierPixels:
    ; Vérifier que Path of Exile 2 est la fenêtre active
    IfWinActive, Path of Exile 2
    {
        tempsActuel := A_TickCount
        delaiDepuisManaAction := tempsActuel - derniereManaAction
        delaiDepuisVieAction := tempsActuel - derniereVieAction
        
        ; --- Vérification du MANA ---
        PixelGetColor, couleurActuelleMana, %manaPosX%, %manaPosY%, RGB
        manaEstPlein := (couleurActuelleMana = manaCouleurPlein)
        EcrireLog("DEBUG: Couleur Mana = " . couleurActuelleMana . " vs référence = " . Format("0x{:06X}", manaCouleurPlein) . " (égal: " . manaEstPlein . ")", false)
        
        if (!manaEstPlein) {  ; Si le mana n'est pas plein
            ; Vérifier le délai depuis la dernière utilisation
            if (delaiDepuisManaAction >= delaiReutilisationPotion || derniereManaAction = 0) {
                Send, %manaTouche%
                EcrireLog("ACTION MANA: Potion utilisée (délai écoulé: " . delaiDepuisManaAction . "ms)", false)
                derniereManaAction := tempsActuel
            } else {
                EcrireLog("ATTENTE MANA: Délai insuffisant (" . delaiDepuisManaAction . "ms / " . delaiReutilisationPotion . "ms)", false)
            }
        }
        
        ; --- Vérification de la VIE ---
        PixelGetColor, couleurActuelleVie, %viePosX%, %viePosY%, RGB
        vieEstPleine := (couleurActuelleVie = vieCouleurPlein)
        EcrireLog("DEBUG: Couleur Vie = " . couleurActuelleVie . " vs référence = " . Format("0x{:06X}", vieCouleurPlein) . " (égal: " . vieEstPleine . ")", false)
        
        if (!vieEstPleine) {  ; Si la vie n'est pas pleine
            ; Vérifier le délai depuis la dernière utilisation
            if (delaiDepuisVieAction >= delaiReutilisationPotion || derniereVieAction = 0) {
                Send, %vieTouche%
                EcrireLog("ACTION VIE: Potion utilisée (délai écoulé: " . delaiDepuisVieAction . "ms)", false)
                derniereVieAction := tempsActuel
            } else {
                EcrireLog("ATTENTE VIE: Délai insuffisant (" . delaiDepuisVieAction . "ms / " . delaiReutilisationPotion . "ms)", false)
            }
        }
    } else {
        ; Log périodique pour indiquer que le jeu n'est pas actif
        Random, rnd, 1, 500  ; Réduit encore plus la fréquence des logs
        if (rnd = 1) {
            WinGetActiveTitle, titre
            EcrireLog("INFO: Fenêtre Path of Exile 2 non active. Fenêtre actuelle: " . titre, false)
        }
    }
return

; Fonction pour recalibrer les couleurs de référence
F5::
    PixelGetColor, nouvelleCouleurMana, %manaPosX%, %manaPosY%, RGB
    PixelGetColor, nouvelleCouleurVie, %viePosX%, %viePosY%, RGB
    
    ; Convertir les valeurs en nombres hexadécimaux
    manaCouleurPlein := nouvelleCouleurMana
    vieCouleurPlein := nouvelleCouleurVie
    
    message := "RECALIBRATION DES COULEURS:`n"
    message .= "Nouvelle couleur mana plein = " . Format("0x{:06X}", manaCouleurPlein) . "`n"
    message .= "Nouvelle couleur vie pleine = " . Format("0x{:06X}", vieCouleurPlein)
    
    EcrireLog(message)
    MsgBox, %message%
    
    ; Réinitialiser les compteurs de temps
    derniereManaAction := 0
    derniereVieAction := 0
return

; Pour tester directement les potions sans vérifier les couleurs (utile pour déboguer)
F6::
    Send, %manaTouche%
    EcrireLog("TEST: Touche mana envoyée manuellement", false)
return

F7::
    Send, %vieTouche%
    EcrireLog("TEST: Touche vie envoyée manuellement", false)
return 
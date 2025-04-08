#NoEnv  ; Recommandé pour les performances et la compatibilité
#SingleInstance force  ; Remplace l'instance précédente du script
SendMode Input  ; Recommandé pour les nouveaux scripts
SetWorkingDir %A_ScriptDir%  ; Garantit la cohérence du répertoire de travail

; Ctrl+X pour capturer les informations du pixel sous le curseur
^x::
  ; Obtenir la position du curseur
  MouseGetPos, xpos, ypos
  
  ; Obtenir la couleur du pixel à cette position
  PixelGetColor, color, %xpos%, %ypos%, RGB
  
  ; Formater la couleur pour qu'elle soit plus lisible (sans le préfixe "0x")
  color := SubStr(color, 3)
  
  ; Afficher un message avec les informations
  MsgBox, Position: X=%xpos% Y=%ypos% `nCouleur: #%color%
  
  ; Copier les informations dans le presse-papiers
  info := "Position: X=" . xpos . " Y=" . ypos . " | Couleur: #" . color
  Clipboard := info
  
  ; Affichage temporaire d'un tooltip pour confirmer que les données sont copiées
  ToolTip, Informations copiées dans le presse-papiers!, %xpos%, %ypos%
  Sleep, 1500
  ToolTip
return 
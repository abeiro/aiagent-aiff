Scriptname AIAgentSpellScript extends Quest  

Spell Property AASpellOne Auto
Spell Property AASpellTwo Auto
Spell Property AASpellThree Auto

EVENT OnInit()
    Actor player = Game.GetPlayer()
    
    if !player.HasSpell(AASpellOne)
        player.AddSpell(AASpellOne)
    EndIf
    
    if !player.HasSpell(AASpellTwo)
        player.AddSpell(AASpellTwo)
    EndIf
    
    if !player.HasSpell(AASpellThree)
        player.AddSpell(AASpellThree)
    EndIf
EndEvent
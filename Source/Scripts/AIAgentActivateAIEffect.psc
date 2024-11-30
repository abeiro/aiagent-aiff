Scriptname AIAgentActivateAIEffect extends activemagiceffect  


Event OnEffectStart(Actor akTarget, Actor akCaster)
  Debug.Trace("Spell was cast on " + akTarget)
  ;Debug.Notification("Spell was cast on " + akTarget.GetDisplayName())
  AIAgentFunctions.setDrivenByAIA(akTarget,true)
endEvent



Scriptname AIAgentDiaryEffect extends activemagiceffect  


Event OnEffectStart(Actor akTarget, Actor akCaster)
  Debug.Trace("Spell was cast on " + akTarget)
  ;Debug.Notification("Spell was cast on " + akTarget)
  AIAgentFunctions.requestMessageForActor("Please, update your diary","diary",akTarget.getDisplayName())
endEvent



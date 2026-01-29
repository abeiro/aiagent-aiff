Scriptname AIAgentSoulGazerEffect extends activemagiceffect  


Event OnEffectStart(Actor akTarget, Actor akCaster)
  Debug.Trace("Magic effect was started on " + akTarget)
  ;Debug.Notification("Magic effect was started on " + akTarget)
  
endEvent



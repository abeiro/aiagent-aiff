Scriptname AIAgentTrackerQuestScript extends Quest  

ReferenceAlias Property AIAgentTrackerQuestAlias Auto
Alias Property AIAgentTrackerQuestLegend Auto

Function QuestNotifySound() global
	
	Debug.Trace("QuestNotifySound start");
	Sound aiqueststart = Game.GetForm(0x00018538) as Sound	; Pututum
	aiqueststart.Play(Game.GetPlayer())
	Debug.Trace("QuestNotifySound end");

EndFunction

Function SetTrackedReference(ObjectReference newRef)
    if newRef
	    AIAgentTrackerQuestAlias.Clear()
        AIAgentTrackerQuestAlias.ForceRefTo(newRef)
		
		PO3_SKSEFunctions.SetObjectiveText(self,"Find "+newRef.GetDisplayName(),20);
		SetObjectiveDisplayed(20, false)
        SetObjectiveDisplayed(20, true)
		
    else
        AIAgentTrackerQuestAlias.Clear()
		;SetObjectiveDisplayed(20, false)

    endif
	
EndFunction

Function SetJournalLog(string messageText)
    
	PO3_SKSEFunctions.SetObjectiveText(self,messageText,10);	
	SetObjectiveDisplayed(10, false)
	SetObjectiveDisplayed(10, true)
	
	
	
EndFunction

Function OnItemPicked()
    Debug.Trace("[CHIM] AIAgentTracker: Item recovered cleaning marker.")
	QuestNotifySound()
    SetObjectiveDisplayed(20, false)
	AIAgentTrackerQuestAlias.ForceRefTo(None)
    
	Reset()

EndFunction

Function OnActorDeath()
    Debug.Trace("[CHIM] AIAgentTracker: Actor killed, cleaning marker.")
	QuestNotifySound()
    SetObjectiveDisplayed(20, false)
	AIAgentTrackerQuestAlias.ForceRefTo(None)
    
	Reset()

EndFunction

Function OnItemActivated()
	QuestNotifySound()
    SetObjectiveDisplayed(20, false)
	AIAgentTrackerQuestAlias.ForceRefTo(None)
    
	Reset()

EndFunction
Scriptname AIAgentItemAliasScript extends ReferenceAlias

Quest Property AIAgentTrackerQuest Auto

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    ; Si el jugador recogió el item
	Debug.Trace("[CHIM] Tracked item changed to "+akNewContainer.GetFormId()+" from "+akOldContainer.GetFormId())
	if (!AIAgentTrackerQuest)
		AIAgentTrackerQuest = Game.GetFormFromFile(0x029E82, "AIAgent.esp") as Quest ; Tracking Quest
	endif
	
    if akNewContainer == Game.GetPlayer()
        (AIAgentTrackerQuest as AIAgentTrackerQuestScript).OnItemPicked()
    endif
EndEvent

Event OnDeath(Actor akKiller)
    ; Si el jugador recogió el item
	Debug.Trace("[CHIM] "+self.GetName()+" killed by  "+akKiller.GetDisplayName())
	if (!AIAgentTrackerQuest)
		AIAgentTrackerQuest = Game.GetFormFromFile(0x029E82, "AIAgent.esp") as Quest ; Tracking Quest
	endif
	
	(AIAgentTrackerQuest as AIAgentTrackerQuestScript).OnActorDeath()

EndEvent
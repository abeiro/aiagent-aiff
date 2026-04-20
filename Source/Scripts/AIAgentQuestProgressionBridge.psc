Scriptname AIAgentQuestProgressionBridge

Quest Function ResolveQuest(int questFormId) global
    return Game.GetFormEx(questFormId) as Quest
EndFunction

Scene Function ResolveScene(int sceneFormId) global
    return Game.GetFormEx(sceneFormId) as Scene
EndFunction

Actor Function ResolveActor(int actorFormId) global
    return Game.GetFormEx(actorFormId) as Actor
EndFunction

ObjectReference Function ResolveReference(int refFormId) global
    return Game.GetFormEx(refFormId) as ObjectReference
EndFunction

Function SetQuestStage(int questFormId, int stage) global
    Quest questRef = ResolveQuest(questFormId)
    if !questRef
        Debug.Trace("[CHIM] QuestBridge: SetQuestStage - quest not found")
        return
    endif

    questRef.SetStage(stage)
EndFunction

Function SetQuestObjectiveCompleted(int questFormId, int objectiveIndex, bool completed = true) global
    Quest questRef = ResolveQuest(questFormId)
    if !questRef
        Debug.Trace("[CHIM] QuestBridge: SetQuestObjectiveCompleted - quest not found")
        return
    endif

    questRef.SetObjectiveCompleted(objectiveIndex, completed)
EndFunction

Function SetQuestObjectiveDisplayed(int questFormId, int objectiveIndex, bool displayed = true, bool forceDisplayed = false) global
    Quest questRef = ResolveQuest(questFormId)
    if !questRef
        Debug.Trace("[CHIM] QuestBridge: SetQuestObjectiveDisplayed - quest not found")
        return
    endif

    questRef.SetObjectiveDisplayed(objectiveIndex, displayed, forceDisplayed)
EndFunction

Function FailAllQuestObjectives(int questFormId) global
    Quest questRef = ResolveQuest(questFormId)
    if !questRef
        Debug.Trace("[CHIM] QuestBridge: FailAllQuestObjectives - quest not found")
        return
    endif

    questRef.FailAllObjectives()
EndFunction

Function StartQuest(int questFormId) global
    Quest questRef = ResolveQuest(questFormId)
    if !questRef
        Debug.Trace("[CHIM] QuestBridge: StartQuest - quest not found")
        return
    endif

    questRef.Start()
EndFunction

Function StopQuest(int questFormId) global
    Quest questRef = ResolveQuest(questFormId)
    if !questRef
        Debug.Trace("[CHIM] QuestBridge: StopQuest - quest not found")
        return
    endif

    questRef.Stop()
EndFunction

Function StartScene(int sceneFormId) global
    Scene sceneRef = ResolveScene(sceneFormId)
    if !sceneRef
        Debug.Trace("[CHIM] QuestBridge: StartScene - scene not found")
        return
    endif

    sceneRef.Start()
EndFunction

Function SetActorValue(int actorFormId, string actorValueName, float actorValue) global
    Actor actorRef = ResolveActor(actorFormId)
    if !actorRef
        Debug.Trace("[CHIM] QuestBridge: SetActorValue - actor not found")
        return
    endif

    actorRef.SetActorValue(actorValueName, actorValue)
EndFunction

Function SetActorGhost(int actorFormId, bool isGhost) global
    Actor actorRef = ResolveActor(actorFormId)
    if !actorRef
        Debug.Trace("[CHIM] QuestBridge: SetActorGhost - actor not found")
        return
    endif

    actorRef.SetGhost(isGhost)
EndFunction

Function EvaluateActorPackage(int actorFormId) global
    Actor actorRef = ResolveActor(actorFormId)
    if !actorRef
        Debug.Trace("[CHIM] QuestBridge: EvaluateActorPackage - actor not found")
        return
    endif

    actorRef.EvaluatePackage()
EndFunction

Function EnableReference(int refFormId, bool fadeIn = false) global
    ObjectReference refObj = ResolveReference(refFormId)
    if !refObj
        Debug.Trace("[CHIM] QuestBridge: EnableReference - reference not found")
        return
    endif

    refObj.Enable(fadeIn)
EndFunction

Function AddItemToPlayer(int itemFormId, int count = 1, bool silent = false) global
    Form itemForm = Game.GetFormEx(itemFormId)
    if !itemForm
        Debug.Trace("[CHIM] QuestBridge: AddItemToPlayer - item not found")
        return
    endif

    if count <= 0
        count = 1
    endif

    Game.GetPlayer().AddItem(itemForm, count, silent)
EndFunction

Function RemoveItemFromPlayer(int itemFormId, int count = 1, bool silent = false) global
    Form itemForm = Game.GetFormEx(itemFormId)
    if !itemForm
        Debug.Trace("[CHIM] QuestBridge: RemoveItemFromPlayer - item not found")
        return
    endif

    if count <= 0
        count = 1
    endif

    Game.GetPlayer().RemoveItem(itemForm, count, silent, None)
EndFunction

Function SetActorRelationshipToPlayer(int actorFormId, int rank) global
    Actor actorRef = ResolveActor(actorFormId)
    if !actorRef
        Debug.Trace("[CHIM] QuestBridge: SetActorRelationshipToPlayer - actor not found")
        return
    endif

    actorRef.SetRelationshipRank(Game.GetPlayer(), rank)
EndFunction

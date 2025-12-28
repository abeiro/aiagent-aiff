Scriptname AIAgentScriptProxy

; =============================================================================
; AIAgentScriptProxy - Global Command Proxy for External AI Integration
;
; Uses safe SKSE helper functions:
;   - jsonGetActor()       → returns Actor
;   - jsonGetReference()   → returns ObjectReference
;   - jsonGetFormId()      → for other Form types (Perk, Spell, etc.)
;
; This avoids unsafe casting from Game.GetFormEx() + 'as Type'.
; =============================================================================

; === Command IDs (Keep synchronized with external AI) ===
; 1 = SetActorValue
; 2 = AddItem
; 3 = RemoveItem
; 4 = MoveTo
; 5 = EquipItem
; 6 = StartCombat
; 7 = Kill
; 8 = ModActorValue
; 9 = DamageActorValue
;10 = RestoreActorValue
;11 = ForceActorValue
;12 = AddPerk
;13 = RemovePerk
;14 = AddSpell
;15 = RemoveSpell
;16 = AddShout
;17 = RemoveShout
;18 = EquipShout
;19 = EquipSpell
;20 = UnequipShout
;21 = UnequipSpell
;22 = EquipItem (with flags)
;23 = UnequipItem
;24 = AddToFaction
;25 = RemoveFromFaction
;26 = SetFactionRank
;27 = ModFactionRank
;28 = EnableAI
;29 = AllowPCDialogue
;30 = SetAlert
;31 = StartSneaking
;32 = Dismount
;33 = OpenInventory
;34 = PlayIdle
;35 = PlayIdleWithTarget
;36 = SetAlpha
;37 = SetGhost
;38 = SetUnconscious
;39 = SetBribed
;40 = SetIntimidated
;41 = SetPlayerTeammate
;42 = SetDoingFavor
;43 = SetRelationshipRank
;45 = SendTrespassAlarm
;46 = StartCannibal
;47 = StartVampireFeed
;48 = StopCombat
;49 = DispelSpell
;51 = SetExpressionOverride
;52 = SetLookAt
;54 = SetHeadTracking
;55 = SetDontMove
;56 = KeepOffsetFromActor
;57 = SetCriticalStage
;58 = SetEyeTexture
;59 = SetOutfit
;60 = SetRace
;61 = SetCrimeFaction
;62 = AllowBleedoutDialogue
;63 = SetNotShowOnStealthMeter
;64 = SetRestrained
;65 = SetNoBleedoutRecovery
;66 = Resurrect
;67 = ResetHealthAndLimbs
;68 = SetPlayerControls
;69 = SetAttackActorOnSight
;70 = SetForcedLandingMarker
;71 = ClearForcedLandingMarker
;73 = PathToReference
;74 = DrawWeapon
;75 = SheatheWeapon
;76 = UnequipAll
;78 = SendLycanthropyStateChanged
;79 = SendVampirismStateChanged
;80 = RemoveFromAllFactions

; === ObjectReference (100–199) ===
; 100 = Activate
; 101 = AddItem
; 102 = RemoveItem
; 103 = Enable
; 104 = Disable
; 105 = Lock
; 106 = Unlock
; 107 = SetOpen
; 108 = AddToMap
; 109 = EnableFastTravel
; 110 = SetLockLevel
; 111 = SetScale
; 112 = SetPosition
; 113 = SetAngle
; 114 = MoveTo
; 115 = ApplyHavokImpulse
; 116 = BlockActivation
; 117 = DamageObject
; 118 = DropObject
; 119 = IgnoreFriendlyHits
; 120 = InterruptCast
; 121 = KnockAreaEffect
; 122 = PushActorAway
; 123 = SetActorOwner
; 124 = SetFactionOwner
; 125 = SetMotionType
; 126 = SetNoFavorAllowed
; 127 = SetDestroyed
; 128 = ClearDestruction
; 129 = SendStealAlarm
; 130 = AddKeyIfNeeded
; 131 = PlaceAtMe

; === Formlist (200–299) ===
; 200 = AddForm
; 201 = RemoveAddedForm
; 202 = Revert

; === EffectShader (300–399) ===
; 300 = Play
; 301 = Stop

; === ActorUtil (400–499) ===
; 400 = AddPackageOverride


; =============================================================================
; MASTER DISPATCH FUNCTION
; =============================================================================
Function ExecuteCommand(int cmdID, string jsonString) global
    if cmdID < 100
        ExecuteCommandActor(cmdID, jsonString)
    elseif cmdID >= 100 && cmdID < 200
        ExecuteCommandObjectReference(cmdID, jsonString)
    elseif cmdID >= 200 && cmdID < 300
        ExecuteCommandFormList(cmdID, jsonString)
	elseif cmdID >= 300 && cmdID < 400
        ExecuteCommandEffectShader(cmdID, jsonString)
	elseif cmdID >= 400 && cmdID < 500
        ExecuteCommandActorUtil(cmdID, jsonString)	
    else
        Debug.Trace("[CHIM] AIProxy: ExecuteCommand - Unsupported cmdID range: " + cmdID)
    endif
EndFunction

; =============================================================================
; ACTOR COMMAND HANDLER (cmdID 1–99)
; =============================================================================
Function ExecuteCommandActor(int cmdID, string jsonString) global
    Debug.Trace("[CHIM] AIProxy: ExecuteCommandActor(cmdID=" + cmdID + ")")
    if cmdID <= 0 || !jsonString
        Debug.Trace("[CHIM] AIProxy: Invalid cmdID or null JSON")
        return
    endif

    Actor akActor = AIAgentFunctions.jsonGetActor("targetObjectFormId", jsonString)
    if !akActor
        Debug.Trace("[CHIM] AIProxy: Target is not a valid Actor")
        return
    endif

    if cmdID == 1 ; SetActorValue
        string asValueName = AIAgentFunctions.jsonGetString("asValueName", jsonString)
        float afValue = AIAgentFunctions.jsonGetFloat("afValue", jsonString)
        if asValueName == ""
            Debug.Trace("[CHIM] AIProxy: SetActorValue - missing asValueName")
            return
        endif
        akActor.SetActorValue(asValueName, afValue)
        Debug.Trace("[CHIM] AIProxy: SetActorValue SUCCESS")

    elseif cmdID == 6 ; StartCombat
        Actor akTarget = AIAgentFunctions.jsonGetActor("akTarget", jsonString)
        if !akTarget
            Debug.Trace("[CHIM] AIProxy: StartCombat - invalid akTarget")
            return
        endif
        akActor.StartCombat(akTarget)
        Debug.Trace("[CHIM] AIProxy: StartCombat SUCCESS")

    elseif cmdID == 7 ; Kill
        akActor.Kill()
        Debug.Trace("[CHIM] AIProxy: Kill SUCCESS")

    elseif cmdID == 8 ; ModActorValue
        string asValueName = AIAgentFunctions.jsonGetString("asValueName", jsonString)
        float afAmount = AIAgentFunctions.jsonGetFloat("afAmount", jsonString)
        if asValueName == ""
            Debug.Trace("[CHIM] AIProxy: ModActorValue - missing asValueName")
            return
        endif
        akActor.ModActorValue(asValueName, afAmount)
        Debug.Trace("[CHIM] AIProxy: ModActorValue SUCCESS")

    elseif cmdID == 9 ; DamageActorValue
        string asValueName = AIAgentFunctions.jsonGetString("asValueName", jsonString)
        float afDamage = AIAgentFunctions.jsonGetFloat("afDamage", jsonString)
        if asValueName == ""
            Debug.Trace("[CHIM] AIProxy: DamageActorValue - missing asValueName")
            return
        endif
        akActor.DamageActorValue(asValueName, afDamage)
        Debug.Trace("[CHIM] AIProxy: DamageActorValue SUCCESS")

    elseif cmdID == 10 ; RestoreActorValue
        string asValueName = AIAgentFunctions.jsonGetString("asValueName", jsonString)
        float afAmount = AIAgentFunctions.jsonGetFloat("afAmount", jsonString)
        if asValueName == ""
            Debug.Trace("[CHIM] AIProxy: RestoreActorValue - missing asValueName")
            return
        endif
        akActor.RestoreActorValue(asValueName, afAmount)
        Debug.Trace("[CHIM] AIProxy: RestoreActorValue SUCCESS")

    elseif cmdID == 11 ; ForceActorValue
        string asValueName = AIAgentFunctions.jsonGetString("asValueName", jsonString)
        float afNewValue = AIAgentFunctions.jsonGetFloat("afNewValue", jsonString)
        if asValueName == ""
            Debug.Trace("[CHIM] AIProxy: ForceActorValue - missing asValueName")
            return
        endif
        akActor.ForceActorValue(asValueName, afNewValue)
        Debug.Trace("[CHIM] AIProxy: ForceActorValue SUCCESS")

    elseif cmdID == 12 ; AddPerk
        int perkID = AIAgentFunctions.jsonGetFormId("akPerk", jsonString)
        if perkID == 0
            Debug.Trace("[CHIM] AIProxy: AddPerk - missing akPerk")
            return
        endif
        Perk akPerk = Game.GetFormEx(perkID) as Perk
        if !akPerk
            Debug.Trace("[CHIM] AIProxy: AddPerk - perk not found")
            return
        endif
        akActor.AddPerk(akPerk)
        Debug.Trace("[CHIM] AIProxy: AddPerk SUCCESS")

    elseif cmdID == 13 ; RemovePerk
        int perkID = AIAgentFunctions.jsonGetFormId("akPerk", jsonString)
        if perkID == 0
            Debug.Trace("[CHIM] AIProxy: RemovePerk - missing akPerk")
            return
        endif
        Perk akPerk = Game.GetFormEx(perkID) as Perk
        if !akPerk
            Debug.Trace("[CHIM] AIProxy: RemovePerk - perk not found")
            return
        endif
        akActor.RemovePerk(akPerk)
        Debug.Trace("[CHIM] AIProxy: RemovePerk SUCCESS")

    elseif cmdID == 14 ; AddSpell
        int spellID = AIAgentFunctions.jsonGetFormId("akSpell", jsonString)
        int abVerbose = AIAgentFunctions.jsonGetInt("abVerbose", jsonString)
        if spellID == 0
            Debug.Trace("[CHIM] AIProxy: AddSpell - missing akSpell")
            return
        endif
        Spell akSpell = Game.GetFormEx(spellID) as Spell
        if !akSpell
            Debug.Trace("[CHIM] AIProxy: AddSpell - spell not found")
            return
        endif
        akActor.AddSpell(akSpell, (abVerbose != 0))
        Debug.Trace("[CHIM] AIProxy: AddSpell SUCCESS")

    elseif cmdID == 15 ; RemoveSpell
        int spellID = AIAgentFunctions.jsonGetFormId("akSpell", jsonString)
        if spellID == 0
            Debug.Trace("[CHIM] AIProxy: RemoveSpell - missing akSpell")
            return
        endif
        Spell akSpell = Game.GetFormEx(spellID) as Spell
        if !akSpell
            Debug.Trace("[CHIM] AIProxy: RemoveSpell - spell not found")
            return
        endif
        akActor.RemoveSpell(akSpell)
        Debug.Trace("[CHIM] AIProxy: RemoveSpell SUCCESS")

    elseif cmdID == 16 ; AddShout
        int shoutID = AIAgentFunctions.jsonGetFormId("akShout", jsonString)
        if shoutID == 0
            Debug.Trace("[CHIM] AIProxy: AddShout - missing akShout")
            return
        endif
        Shout akShout = Game.GetFormEx(shoutID) as Shout
        if !akShout
            Debug.Trace("[CHIM] AIProxy: AddShout - shout not found")
            return
        endif
        akActor.AddShout(akShout)
        Debug.Trace("[CHIM] AIProxy: AddShout SUCCESS")

    elseif cmdID == 17 ; RemoveShout
        int shoutID = AIAgentFunctions.jsonGetFormId("akShout", jsonString)
        if shoutID == 0
            Debug.Trace("[CHIM] AIProxy: RemoveShout - missing akShout")
            return
        endif
        Shout akShout = Game.GetFormEx(shoutID) as Shout
        if !akShout
            Debug.Trace("[CHIM] AIProxy: RemoveShout - shout not found")
            return
        endif
        akActor.RemoveShout(akShout)
        Debug.Trace("[CHIM] AIProxy: RemoveShout SUCCESS")

    elseif cmdID == 18 ; EquipShout
        int shoutID = AIAgentFunctions.jsonGetFormId("akShout", jsonString)
        if shoutID == 0
            Debug.Trace("[CHIM] AIProxy: EquipShout - missing akShout")
            return
        endif
        Shout akShout = Game.GetFormEx(shoutID) as Shout
        if !akShout
            Debug.Trace("[CHIM] AIProxy: EquipShout - shout not found")
            return
        endif
        akActor.EquipShout(akShout)
        Debug.Trace("[CHIM] AIProxy: EquipShout SUCCESS")

    elseif cmdID == 19 ; EquipSpell
        int spellID = AIAgentFunctions.jsonGetFormId("akSpell", jsonString)
        int aiSource = AIAgentFunctions.jsonGetInt("aiSource", jsonString)
        if spellID == 0
            Debug.Trace("[CHIM] AIProxy: EquipSpell - missing akSpell")
            return
        endif
        Spell akSpell = Game.GetFormEx(spellID) as Spell
        if !akSpell
            Debug.Trace("[CHIM] AIProxy: EquipSpell - spell not found")
            return
        endif
        akActor.EquipSpell(akSpell, aiSource)
        Debug.Trace("[CHIM] AIProxy: EquipSpell SUCCESS")

    elseif cmdID == 20 ; UnequipShout
        int shoutID = AIAgentFunctions.jsonGetFormId("akShout", jsonString)
        if shoutID == 0
            Debug.Trace("[CHIM] AIProxy: UnequipShout - missing akShout")
            return
        endif
        Shout akShout = Game.GetFormEx(shoutID) as Shout
        if !akShout
            Debug.Trace("[CHIM] AIProxy: UnequipShout - shout not found")
            return
        endif
        akActor.UnequipShout(akShout)
        Debug.Trace("[CHIM] AIProxy: UnequipShout SUCCESS")

    elseif cmdID == 21 ; UnequipSpell
        int spellID = AIAgentFunctions.jsonGetFormId("akSpell", jsonString)
        int aiSource = AIAgentFunctions.jsonGetInt("aiSource", jsonString)
        if spellID == 0
            Debug.Trace("[CHIM] AIProxy: UnequipSpell - missing akSpell")
            return
        endif
        Spell akSpell = Game.GetFormEx(spellID) as Spell
        if !akSpell
            Debug.Trace("[CHIM] AIProxy: UnequipSpell - spell not found")
            return
        endif
        akActor.UnequipSpell(akSpell, aiSource)
        Debug.Trace("[CHIM] AIProxy: UnequipSpell SUCCESS")

    elseif cmdID == 22 ; EquipItem
        int itemID = AIAgentFunctions.jsonGetFormId("akItem", jsonString)
        if itemID == 0
            Debug.Trace("[CHIM] AIProxy: EquipItem - missing akItem")
            return
        endif
        Form akItem = Game.GetFormEx(itemID)
        if !akItem
            Debug.Trace("[CHIM] AIProxy: EquipItem - item not found")
            return
        endif
        int abPreventRemoval = AIAgentFunctions.jsonGetInt("abPreventRemoval", jsonString)
        int abSilent = AIAgentFunctions.jsonGetInt("abSilent", jsonString)
        akActor.EquipItem(akItem, (abPreventRemoval != 0), (abSilent != 0))
        Debug.Trace("[CHIM] AIProxy: EquipItem SUCCESS")

    elseif cmdID == 23 ; UnequipItem
        int itemID = AIAgentFunctions.jsonGetFormId("akItem", jsonString)
        if itemID == 0
            Debug.Trace("[CHIM] AIProxy: UnequipItem - missing akItem")
            return
        endif
        Form akItem = Game.GetFormEx(itemID)
        if !akItem
            Debug.Trace("[CHIM] AIProxy: UnequipItem - item not found")
            return
        endif
        int abPreventEquip = AIAgentFunctions.jsonGetInt("abPreventEquip", jsonString)
        int abSilent = AIAgentFunctions.jsonGetInt("abSilent", jsonString)
        akActor.UnequipItem(akItem, (abPreventEquip != 0), (abSilent != 0))
        Debug.Trace("[CHIM] AIProxy: UnequipItem SUCCESS")

    elseif cmdID == 24 ; AddToFaction
        int factionID = AIAgentFunctions.jsonGetFormId("akFaction", jsonString)
        if factionID == 0
            Debug.Trace("[CHIM] AIProxy: AddToFaction - missing akFaction")
            return
        endif
        Faction akFaction = Game.GetFormEx(factionID) as Faction
        if !akFaction
            Debug.Trace("[CHIM] AIProxy: AddToFaction - faction not found")
            return
        endif
        akActor.AddToFaction(akFaction)
        Debug.Trace("[CHIM] AIProxy: AddToFaction SUCCESS")

    elseif cmdID == 25 ; RemoveFromFaction
        int factionID = AIAgentFunctions.jsonGetFormId("akFaction", jsonString)
        if factionID == 0
            Debug.Trace("[CHIM] AIProxy: RemoveFromFaction - missing akFaction")
            return
        endif
        Faction akFaction = Game.GetFormEx(factionID) as Faction
        if !akFaction
            Debug.Trace("[CHIM] AIProxy: RemoveFromFaction - faction not found")
            return
        endif
        akActor.RemoveFromFaction(akFaction)
        Debug.Trace("[CHIM] AIProxy: RemoveFromFaction SUCCESS")

    elseif cmdID == 26 ; SetFactionRank
        int factionID = AIAgentFunctions.jsonGetFormId("akFaction", jsonString)
        int aiRank = AIAgentFunctions.jsonGetInt("aiRank", jsonString)
        if factionID == 0 || aiRank == 0 && AIAgentFunctions.jsonGetString("aiRank", jsonString) == ""
            Debug.Trace("[CHIM] AIProxy: SetFactionRank - missing akFaction or aiRank")
            return
        endif
        Faction akFaction = Game.GetFormEx(factionID) as Faction
        if !akFaction
            Debug.Trace("[CHIM] AIProxy: SetFactionRank - faction not found")
            return
        endif
        akActor.SetFactionRank(akFaction, aiRank)
        Debug.Trace("[CHIM] AIProxy: SetFactionRank SUCCESS")

    elseif cmdID == 27 ; ModFactionRank
        int factionID = AIAgentFunctions.jsonGetFormId("akFaction", jsonString)
        int aiMod = AIAgentFunctions.jsonGetInt("aiMod", jsonString)
        if factionID == 0
            Debug.Trace("[CHIM] AIProxy: ModFactionRank - missing akFaction")
            return
        endif
        Faction akFaction = Game.GetFormEx(factionID) as Faction
        if !akFaction
            Debug.Trace("[CHIM] AIProxy: ModFactionRank - faction not found")
            return
        endif
        akActor.ModFactionRank(akFaction, aiMod)
        Debug.Trace("[CHIM] AIProxy: ModFactionRank SUCCESS")

    elseif cmdID == 28 ; EnableAI
        int abEnable = AIAgentFunctions.jsonGetInt("abEnable", jsonString)
        akActor.EnableAI((abEnable != 0))
        Debug.Trace("[CHIM] AIProxy: EnableAI SUCCESS")

    elseif cmdID == 29 ; AllowPCDialogue
        int abTalk = AIAgentFunctions.jsonGetInt("abTalk", jsonString)
        akActor.AllowPCDialogue((abTalk != 0))
        Debug.Trace("[CHIM] AIProxy: AllowPCDialogue SUCCESS")

    elseif cmdID == 30 ; SetAlert
        int abAlerted = AIAgentFunctions.jsonGetInt("abAlerted", jsonString)
        akActor.SetAlert((abAlerted != 0))
        Debug.Trace("[CHIM] AIProxy: SetAlert SUCCESS")

    elseif cmdID == 31 ; StartSneaking
        akActor.StartSneaking()
        Debug.Trace("[CHIM] AIProxy: StartSneaking SUCCESS")

    elseif cmdID == 32 ; Dismount
        akActor.Dismount()
        Debug.Trace("[CHIM] AIProxy: Dismount SUCCESS")

    elseif cmdID == 33 ; OpenInventory
        int abForceOpen = AIAgentFunctions.jsonGetInt("abForceOpen", jsonString)
        akActor.OpenInventory((abForceOpen != 0))
        Debug.Trace("[CHIM] AIProxy: OpenInventory SUCCESS")

    elseif cmdID == 34 ; PlayIdle
        int idleID = AIAgentFunctions.jsonGetFormId("akIdle", jsonString)
        if idleID == 0
            Debug.Trace("[CHIM] AIProxy: PlayIdle - missing akIdle")
            return
        endif
        Idle akIdle = Game.GetFormEx(idleID) as Idle
        if !akIdle
            Debug.Trace("[CHIM] AIProxy: PlayIdle - idle not found")
            return
        endif
        akActor.PlayIdle(akIdle)
        Debug.Trace("[CHIM] AIProxy: PlayIdle SUCCESS")

    elseif cmdID == 35 ; PlayIdleWithTarget
        int idleID = AIAgentFunctions.jsonGetFormId("akIdle", jsonString)
        ObjectReference akTarget = AIAgentFunctions.jsonGetReference("akTarget", jsonString)
        if idleID == 0 || !akTarget
            Debug.Trace("[CHIM] AIProxy: PlayIdleWithTarget - missing akIdle or akTarget")
            return
        endif
        Idle akIdle = Game.GetFormEx(idleID) as Idle
        if !akIdle
            Debug.Trace("[CHIM] AIProxy: PlayIdleWithTarget - idle not found")
            return
        endif
        akActor.PlayIdleWithTarget(akIdle, akTarget)
        Debug.Trace("[CHIM] AIProxy: PlayIdleWithTarget SUCCESS")

    elseif cmdID == 36 ; SetAlpha
        float afTargetAlpha = AIAgentFunctions.jsonGetFloat("afTargetAlpha", jsonString)
        int abFade = AIAgentFunctions.jsonGetInt("abFade", jsonString)
        akActor.SetAlpha(afTargetAlpha, (abFade != 0))
        Debug.Trace("[CHIM] AIProxy: SetAlpha SUCCESS")

    elseif cmdID == 37 ; SetGhost
        int abIsGhost = AIAgentFunctions.jsonGetInt("abIsGhost", jsonString)
        akActor.SetGhost((abIsGhost != 0))
        Debug.Trace("[CHIM] AIProxy: SetGhost SUCCESS")

    elseif cmdID == 38 ; SetUnconscious
        int abIsUnconscious = AIAgentFunctions.jsonGetInt("abIsUnconscious", jsonString)
        akActor.SetUnconscious((abIsUnconscious != 0))
        Debug.Trace("[CHIM] AIProxy: SetUnconscious SUCCESS")

    elseif cmdID == 39 ; SetBribed
        int abBribe = AIAgentFunctions.jsonGetInt("abBribe", jsonString)
        akActor.SetBribed((abBribe != 0))
        Debug.Trace("[CHIM] AIProxy: SetBribed SUCCESS")

    elseif cmdID == 40 ; SetIntimidated
        int abIntimidate = AIAgentFunctions.jsonGetInt("abIntimidate", jsonString)
        akActor.SetIntimidated((abIntimidate != 0))
        Debug.Trace("[CHIM] AIProxy: SetIntimidated SUCCESS")

    elseif cmdID == 41 ; SetPlayerTeammate
        int abTeammate = AIAgentFunctions.jsonGetInt("abTeammate", jsonString)
        int abCanDoFavor = AIAgentFunctions.jsonGetInt("abCanDoFavor", jsonString)
        akActor.SetPlayerTeammate((abTeammate != 0), (abCanDoFavor != 0))
        Debug.Trace("[CHIM] AIProxy: SetPlayerTeammate SUCCESS")

    elseif cmdID == 42 ; SetDoingFavor
        int abDoingFavor = AIAgentFunctions.jsonGetInt("abDoingFavor", jsonString)
        akActor.SetDoingFavor((abDoingFavor != 0))
        Debug.Trace("[CHIM] AIProxy: SetDoingFavor SUCCESS")

    elseif cmdID == 43 ; SetRelationshipRank
        Actor akOther = AIAgentFunctions.jsonGetActor("akOther", jsonString)
        int aiRank = AIAgentFunctions.jsonGetInt("aiRank", jsonString)
        if !akOther
            Debug.Trace("[CHIM] AIProxy: SetRelationshipRank - invalid akOther")
            return
        endif
        akActor.SetRelationshipRank(akOther, aiRank)
        Debug.Trace("[CHIM] AIProxy: SetRelationshipRank SUCCESS")

    elseif cmdID == 45 ; SendTrespassAlarm
        Actor akCriminal = AIAgentFunctions.jsonGetActor("akCriminal", jsonString)
        if !akCriminal
            Debug.Trace("[CHIM] AIProxy: SendTrespassAlarm - invalid akCriminal")
            return
        endif
        akActor.SendTrespassAlarm(akCriminal)
        Debug.Trace("[CHIM] AIProxy: SendTrespassAlarm SUCCESS")

    elseif cmdID == 46 ; StartCannibal
        Actor akTarget = AIAgentFunctions.jsonGetActor("akTarget", jsonString)
        if !akTarget
            Debug.Trace("[CHIM] AIProxy: StartCannibal - invalid akTarget")
            return
        endif
        akActor.StartCannibal(akTarget)
        Debug.Trace("[CHIM] AIProxy: StartCannibal SUCCESS")

    elseif cmdID == 47 ; StartVampireFeed
        Actor akTarget = AIAgentFunctions.jsonGetActor("akTarget", jsonString)
        if !akTarget
            Debug.Trace("[CHIM] AIProxy: StartVampireFeed - invalid akTarget")
            return
        endif
        akActor.StartVampireFeed(akTarget)
        Debug.Trace("[CHIM] AIProxy: StartVampireFeed SUCCESS")

    elseif cmdID == 48 ; StopCombat
        akActor.StopCombat()
        Debug.Trace("[CHIM] AIProxy: StopCombat SUCCESS")

    elseif cmdID == 49 ; DispelSpell
        int spellID = AIAgentFunctions.jsonGetFormId("akSpell", jsonString)
        if spellID == 0
            Debug.Trace("[CHIM] AIProxy: DispelSpell - missing akSpell")
            return
        endif
        Spell akSpell = Game.GetFormEx(spellID) as Spell
        if !akSpell
            Debug.Trace("[CHIM] AIProxy: DispelSpell - spell not found")
            return
        endif
        akActor.DispelSpell(akSpell)
        Debug.Trace("[CHIM] AIProxy: DispelSpell SUCCESS")

    elseif cmdID == 51 ; SetExpressionOverride
        int aiMood = AIAgentFunctions.jsonGetInt("aiMood", jsonString)
        int aiStrength = AIAgentFunctions.jsonGetInt("aiStrength", jsonString)
        akActor.SetExpressionOverride(aiMood, aiStrength)
        Debug.Trace("[CHIM] AIProxy: SetExpressionOverride SUCCESS")

    elseif cmdID == 52 ; SetLookAt
        ObjectReference akTarget = AIAgentFunctions.jsonGetReference("akTarget", jsonString)
        int abPathingLookAt = AIAgentFunctions.jsonGetInt("abPathingLookAt", jsonString)
        if !akTarget
            Debug.Trace("[CHIM] AIProxy: SetLookAt - invalid akTarget")
            return
        endif
        akActor.SetLookAt(akTarget, (abPathingLookAt != 0))
        Debug.Trace("[CHIM] AIProxy: SetLookAt SUCCESS")

    elseif cmdID == 54 ; SetHeadTracking
        int abEnable = AIAgentFunctions.jsonGetInt("abEnable", jsonString)
        akActor.SetHeadTracking((abEnable != 0))
        Debug.Trace("[CHIM] AIProxy: SetHeadTracking SUCCESS")

    elseif cmdID == 55 ; SetDontMove
        int abDontMove = AIAgentFunctions.jsonGetInt("abDontMove", jsonString)
        akActor.SetDontMove((abDontMove != 0))
        Debug.Trace("[CHIM] AIProxy: SetDontMove SUCCESS")

    elseif cmdID == 56 ; KeepOffsetFromActor
        Actor arTarget = AIAgentFunctions.jsonGetActor("arTarget", jsonString)
        if !arTarget
            Debug.Trace("[CHIM] AIProxy: KeepOffsetFromActor - missing arTarget")
            return
        endif
        float afOffsetX = AIAgentFunctions.jsonGetFloat("afOffsetX", jsonString)
        float afOffsetY = AIAgentFunctions.jsonGetFloat("afOffsetY", jsonString)
        float afOffsetZ = AIAgentFunctions.jsonGetFloat("afOffsetZ", jsonString)
        float afOffsetAngleX = AIAgentFunctions.jsonGetFloat("afOffsetAngleX", jsonString)
        float afOffsetAngleY = AIAgentFunctions.jsonGetFloat("afOffsetAngleY", jsonString)
        float afOffsetAngleZ = AIAgentFunctions.jsonGetFloat("afOffsetAngleZ", jsonString)
        float afCatchUpRadius = AIAgentFunctions.jsonGetFloat("afCatchUpRadius", jsonString)
        float afFollowRadius = AIAgentFunctions.jsonGetFloat("afFollowRadius", jsonString)
        akActor.KeepOffsetFromActor(arTarget, afOffsetX, afOffsetY, afOffsetZ, afOffsetAngleX, afOffsetAngleY, afOffsetAngleZ, afCatchUpRadius, afFollowRadius)
        Debug.Trace("[CHIM] AIProxy: KeepOffsetFromActor SUCCESS")

    elseif cmdID == 57 ; SetCriticalStage
        int aiStage = AIAgentFunctions.jsonGetInt("aiStage", jsonString)
        akActor.SetCriticalStage(aiStage)
        Debug.Trace("[CHIM] AIProxy: SetCriticalStage SUCCESS")

    elseif cmdID == 58 ; SetEyeTexture
        int textureID = AIAgentFunctions.jsonGetFormId("akTexture", jsonString)
        if textureID == 0
            Debug.Trace("[CHIM] AIProxy: SetEyeTexture - missing akTexture")
            return
        endif
        TextureSet akTexture = Game.GetFormEx(textureID) as TextureSet
        if !akTexture
            Debug.Trace("[CHIM] AIProxy: SetEyeTexture - texture not found")
            return
        endif
        akActor.SetEyeTexture(akTexture)
        Debug.Trace("[CHIM] AIProxy: SetEyeTexture SUCCESS")

    elseif cmdID == 59 ; SetOutfit
        int outfitID = AIAgentFunctions.jsonGetFormId("akOutfit", jsonString)
        if outfitID == 0
            Debug.Trace("[CHIM] AIProxy: SetOutfit - missing akOutfit")
            return
        endif
        Outfit akOutfit = Game.GetFormEx(outfitID) as Outfit
        if !akOutfit
            Debug.Trace("[CHIM] AIProxy: SetOutfit - outfit not found")
            return
        endif
        int abSleepOutfit = AIAgentFunctions.jsonGetInt("abSleepOutfit", jsonString)
        akActor.SetOutfit(akOutfit, (abSleepOutfit != 0))
        Debug.Trace("[CHIM] AIProxy: SetOutfit SUCCESS")

    elseif cmdID == 60 ; SetRace
        int raceID = AIAgentFunctions.jsonGetFormId("akRace", jsonString)
        if raceID == 0
            Debug.Trace("[CHIM] AIProxy: SetRace - missing akRace")
            return
        endif
        Race akRace = Game.GetFormEx(raceID) as Race
        if !akRace
            Debug.Trace("[CHIM] AIProxy: SetRace - race not found")
            return
        endif
        akActor.SetRace(akRace)
        Debug.Trace("[CHIM] AIProxy: SetRace SUCCESS")

    elseif cmdID == 61 ; SetCrimeFaction
        int factionID = AIAgentFunctions.jsonGetFormId("akFaction", jsonString)
        if factionID == 0
            Debug.Trace("[CHIM] AIProxy: SetCrimeFaction - missing akFaction")
            return
        endif
        Faction akFaction = Game.GetFormEx(factionID) as Faction
        if !akFaction
            Debug.Trace("[CHIM] AIProxy: SetCrimeFaction - faction not found")
            return
        endif
        akActor.SetCrimeFaction(akFaction)
        Debug.Trace("[CHIM] AIProxy: SetCrimeFaction SUCCESS")

    elseif cmdID == 62 ; AllowBleedoutDialogue
        int abCanTalk = AIAgentFunctions.jsonGetInt("abCanTalk", jsonString)
        akActor.AllowBleedoutDialogue((abCanTalk != 0))
        Debug.Trace("[CHIM] AIProxy: AllowBleedoutDialogue SUCCESS")

    elseif cmdID == 63 ; SetNotShowOnStealthMeter
        int abNotShow = AIAgentFunctions.jsonGetInt("abNotShow", jsonString)
        akActor.SetNotShowOnStealthMeter((abNotShow != 0))
        Debug.Trace("[CHIM] AIProxy: SetNotShowOnStealthMeter SUCCESS")

    elseif cmdID == 64 ; SetRestrained
        int abRestrained = AIAgentFunctions.jsonGetInt("abRestrained", jsonString)
        akActor.SetRestrained((abRestrained != 0))
        Debug.Trace("[CHIM] AIProxy: SetRestrained SUCCESS")

    elseif cmdID == 65 ; SetNoBleedoutRecovery
        int abAllowed = AIAgentFunctions.jsonGetInt("abAllowed", jsonString)
        akActor.SetNoBleedoutRecovery((abAllowed != 0))
        Debug.Trace("[CHIM] AIProxy: SetNoBleedoutRecovery SUCCESS")

    elseif cmdID == 66 ; Resurrect
        akActor.Resurrect()
        Debug.Trace("[CHIM] AIProxy: Resurrect SUCCESS")

    elseif cmdID == 67 ; ResetHealthAndLimbs
        akActor.ResetHealthAndLimbs()
        Debug.Trace("[CHIM] AIProxy: ResetHealthAndLimbs SUCCESS")

    elseif cmdID == 68 ; SetPlayerControls
        int abControls = AIAgentFunctions.jsonGetInt("abControls", jsonString)
        akActor.SetPlayerControls((abControls != 0))
        Debug.Trace("[CHIM] AIProxy: SetPlayerControls SUCCESS")

    elseif cmdID == 69 ; SetAttackActorOnSight
        int abAttackOnSight = AIAgentFunctions.jsonGetInt("abAttackOnSight", jsonString)
        akActor.SetAttackActorOnSight((abAttackOnSight != 0))
        Debug.Trace("[CHIM] AIProxy: SetAttackActorOnSight SUCCESS")

    elseif cmdID == 70 ; SetForcedLandingMarker
        ObjectReference aMarker = AIAgentFunctions.jsonGetReference("aMarker", jsonString)
        if !aMarker
            Debug.Trace("[CHIM] AIProxy: SetForcedLandingMarker - invalid aMarker")
            return
        endif
        akActor.SetForcedLandingMarker(aMarker)
        Debug.Trace("[CHIM] AIProxy: SetForcedLandingMarker SUCCESS")

    elseif cmdID == 71 ; ClearForcedLandingMarker
        akActor.ClearForcedLandingMarker()
        Debug.Trace("[CHIM] AIProxy: ClearForcedLandingMarker SUCCESS")

    elseif cmdID == 73 ; PathToReference
        ObjectReference aTarget = AIAgentFunctions.jsonGetReference("aTarget", jsonString)
        float afWalkRunPercent = AIAgentFunctions.jsonGetFloat("afWalkRunPercent", jsonString)
        if !aTarget
            Debug.Trace("[CHIM] AIProxy: PathToReference - invalid aTarget")
            return
        endif
        akActor.PathToReference(aTarget, afWalkRunPercent)
        Debug.Trace("[CHIM] AIProxy: PathToReference SUCCESS")

    elseif cmdID == 74 ; DrawWeapon
        akActor.DrawWeapon()
        Debug.Trace("[CHIM] AIProxy: DrawWeapon SUCCESS")

    elseif cmdID == 75 ; SheatheWeapon
        akActor.SheatheWeapon()
        Debug.Trace("[CHIM] AIProxy: SheatheWeapon SUCCESS")

    elseif cmdID == 76 ; UnequipAll
        akActor.UnequipAll()
        Debug.Trace("[CHIM] AIProxy: UnequipAll SUCCESS")

    elseif cmdID == 78 ; SendLycanthropyStateChanged
        int abIsWerewolf = AIAgentFunctions.jsonGetInt("abIsWerewolf", jsonString)
        akActor.SendLycanthropyStateChanged((abIsWerewolf != 0))
        Debug.Trace("[CHIM] AIProxy: SendLycanthropyStateChanged SUCCESS")

    elseif cmdID == 79 ; SendVampirismStateChanged
        int abIsVampire = AIAgentFunctions.jsonGetInt("abIsVampire", jsonString)
        akActor.SendVampirismStateChanged((abIsVampire != 0))
        Debug.Trace("[CHIM] AIProxy: SendVampirismStateChanged SUCCESS")
    elseif cmdID == 80 ; RemoveFromAllFactions
        akActor.RemoveFromAllFactions()
        Debug.Trace("[CHIM] AIProxy: RemoveFromAllFactions SUCCESS")
    elseif cmdID == 81 ; EvaluatePackage
        akActor.EvaluatePackage()
        Debug.Trace("[CHIM] AIProxy: EvaluatePackage SUCCESS")
	else
        Debug.Trace("[CHIM] AIProxy: UNKNOWN Actor cmdID: " + cmdID)
    endif
EndFunction

; =============================================================================
; OBJECTREFERENCE COMMAND HANDLER (cmdID 100–199)
; =============================================================================
Function ExecuteCommandObjectReference(int cmdID, string jsonString) global
    Debug.Trace("[CHIM] AIProxy: ExecuteCommandObjectReference(cmdID=" + cmdID + ")")
    if cmdID <= 0 || !jsonString
        Debug.Trace("[CHIM] AIProxy: Invalid cmdID or null JSON")
        return
    endif

    ObjectReference akRef = AIAgentFunctions.jsonGetReference("targetObjectFormId", jsonString)
    if !akRef
        Debug.Trace("[CHIM] AIProxy: Target is not a valid ObjectReference")
        return
    endif

    if cmdID == 100 ; Activate
        ObjectReference akActivator = AIAgentFunctions.jsonGetReference("akActivator", jsonString)
        if !akActivator
            Debug.Trace("[CHIM] AIProxy: Activate - invalid akActivator")
            return
        endif
        akRef.Activate(akActivator)
        Debug.Trace("[CHIM] AIProxy: Activate SUCCESS")

    elseif cmdID == 101 ; AddItem
        int itemID = AIAgentFunctions.jsonGetFormId("akItemToAdd", jsonString)
        if itemID == 0
            Debug.Trace("[CHIM] AIProxy: AddItem - missing akItemToAdd")
            return
        endif
        Form akItem = Game.GetFormEx(itemID)
        if !akItem
            Debug.Trace("[CHIM] AIProxy: AddItem - item not found")
            return
        endif
        int aiCount = AIAgentFunctions.jsonGetInt("aiCount", jsonString)
        if aiCount <= 0
            aiCount = 1
        endif
        int abSilent = AIAgentFunctions.jsonGetInt("abSilent", jsonString)
        akRef.AddItem(akItem, aiCount, (abSilent != 0))
        Debug.Trace("[CHIM] AIProxy: AddItem SUCCESS")

    elseif cmdID == 102 ; RemoveItem
        int itemID = AIAgentFunctions.jsonGetFormId("akItemToRemove", jsonString)
        if itemID == 0
            Debug.Trace("[CHIM] AIProxy: RemoveItem - missing akItemToRemove")
            return
        endif
        Form akItem = Game.GetFormEx(itemID)
        if !akItem
            Debug.Trace("[CHIM] AIProxy: RemoveItem - item not found")
            return
        endif
        int aiCount = AIAgentFunctions.jsonGetInt("aiCount", jsonString)
        if aiCount <= 0
            aiCount = 1
        endif
        int abSilent = AIAgentFunctions.jsonGetInt("abSilent", jsonString)
        akRef.RemoveItem(akItem, aiCount, (abSilent != 0), none)
        Debug.Trace("[CHIM] AIProxy: RemoveItem SUCCESS")

    elseif cmdID == 103 ; Enable
        int abFadeIn = AIAgentFunctions.jsonGetInt("abFadeIn", jsonString)
        akRef.Enable((abFadeIn != 0))
        Debug.Trace("[CHIM] AIProxy: Enable SUCCESS")

    elseif cmdID == 104 ; Disable
        int abFadeOut = AIAgentFunctions.jsonGetInt("abFadeOut", jsonString)
        akRef.Disable((abFadeOut != 0))
        Debug.Trace("[CHIM] AIProxy: Disable SUCCESS")

    elseif cmdID == 105 ; Lock
        int abLock = AIAgentFunctions.jsonGetInt("abLock", jsonString)
        int abAsOwner = AIAgentFunctions.jsonGetInt("abAsOwner", jsonString)
        akRef.Lock((abLock != 0), (abAsOwner != 0))
        Debug.Trace("[CHIM] AIProxy: Lock SUCCESS")

    elseif cmdID == 106 ; Unlock
        akRef.Lock(false, false)
        Debug.Trace("[CHIM] AIProxy: Unlock SUCCESS")

    elseif cmdID == 107 ; SetOpen
        int abOpen = AIAgentFunctions.jsonGetInt("abOpen", jsonString)
        akRef.SetOpen((abOpen != 0))
        Debug.Trace("[CHIM] AIProxy: SetOpen SUCCESS")

    elseif cmdID == 108 ; AddToMap
        int abAllowFastTravel = AIAgentFunctions.jsonGetInt("abAllowFastTravel", jsonString)
        akRef.AddToMap((abAllowFastTravel != 0))
        Debug.Trace("[CHIM] AIProxy: AddToMap SUCCESS")

    elseif cmdID == 109 ; EnableFastTravel
        int abEnable = AIAgentFunctions.jsonGetInt("abEnable", jsonString)
        akRef.EnableFastTravel((abEnable != 0))
        Debug.Trace("[CHIM] AIProxy: EnableFastTravel SUCCESS")

    elseif cmdID == 110 ; SetLockLevel
        int aiLockLevel = AIAgentFunctions.jsonGetInt("aiLockLevel", jsonString)
        akRef.SetLockLevel(aiLockLevel)
        Debug.Trace("[CHIM] AIProxy: SetLockLevel SUCCESS")

    elseif cmdID == 111 ; SetScale
        float afScale = AIAgentFunctions.jsonGetFloat("afScale", jsonString)
        akRef.SetScale(afScale)
        Debug.Trace("[CHIM] AIProxy: SetScale SUCCESS")

    elseif cmdID == 112 ; SetPosition
        float afX = AIAgentFunctions.jsonGetFloat("afX", jsonString)
        float afY = AIAgentFunctions.jsonGetFloat("afY", jsonString)
        float afZ = AIAgentFunctions.jsonGetFloat("afZ", jsonString)
        akRef.SetPosition(afX, afY, afZ)
        Debug.Trace("[CHIM] AIProxy: SetPosition SUCCESS")

    elseif cmdID == 113 ; SetAngle
        float afXAngle = AIAgentFunctions.jsonGetFloat("afXAngle", jsonString)
        float afYAngle = AIAgentFunctions.jsonGetFloat("afYAngle", jsonString)
        float afZAngle = AIAgentFunctions.jsonGetFloat("afZAngle", jsonString)
        akRef.SetAngle(afXAngle, afYAngle, afZAngle)
        Debug.Trace("[CHIM] AIProxy: SetAngle SUCCESS")

    elseif cmdID == 114 ; MoveTo
        ObjectReference akTarget = AIAgentFunctions.jsonGetReference("akTarget", jsonString)
        if !akTarget
            Debug.Trace("[CHIM] AIProxy: MoveTo - missing akTarget")
            return
        endif
        float afXOffset = AIAgentFunctions.jsonGetFloat("afXOffset", jsonString)
        float afYOffset = AIAgentFunctions.jsonGetFloat("afYOffset", jsonString)
        float afZOffset = AIAgentFunctions.jsonGetFloat("afZOffset", jsonString)
        int abMatchRotation = AIAgentFunctions.jsonGetInt("abMatchRotation", jsonString)
        akRef.MoveTo(akTarget, afXOffset, afYOffset, afZOffset, (abMatchRotation != 0))
        Debug.Trace("[CHIM] AIProxy: MoveTo SUCCESS")

    elseif cmdID == 115 ; ApplyHavokImpulse
        float afX = AIAgentFunctions.jsonGetFloat("afX", jsonString)
        float afY = AIAgentFunctions.jsonGetFloat("afY", jsonString)
        float afZ = AIAgentFunctions.jsonGetFloat("afZ", jsonString)
        float afMagnitude = AIAgentFunctions.jsonGetFloat("afMagnitude", jsonString)
        akRef.ApplyHavokImpulse(afX, afY, afZ, afMagnitude)
        Debug.Trace("[CHIM] AIProxy: ApplyHavokImpulse SUCCESS")

    elseif cmdID == 116 ; BlockActivation
        int abBlocked = AIAgentFunctions.jsonGetInt("abBlocked", jsonString)
        akRef.BlockActivation((abBlocked != 0))
        Debug.Trace("[CHIM] AIProxy: BlockActivation SUCCESS")

    elseif cmdID == 117 ; DamageObject
        float afDamage = AIAgentFunctions.jsonGetFloat("afDamage", jsonString)
        akRef.DamageObject(afDamage)
        Debug.Trace("[CHIM] AIProxy: DamageObject SUCCESS")

    elseif cmdID == 118 ; DropObject
        int itemID = AIAgentFunctions.jsonGetFormId("akObject", jsonString)
        if itemID == 0
            Debug.Trace("[CHIM] AIProxy: DropObject - missing akObject")
            return
        endif
        Form akItem = Game.GetFormEx(itemID)
        if !akItem
            Debug.Trace("[CHIM] AIProxy: DropObject - item not found")
            return
        endif
        int aiCount = AIAgentFunctions.jsonGetInt("aiCount", jsonString)
        if aiCount <= 0
            aiCount = 1
        endif
        akRef.DropObject(akItem, aiCount)
        Debug.Trace("[CHIM] AIProxy: DropObject SUCCESS")

    elseif cmdID == 119 ; IgnoreFriendlyHits
        int abIgnore = AIAgentFunctions.jsonGetInt("abIgnore", jsonString)
        akRef.IgnoreFriendlyHits((abIgnore != 0))
        Debug.Trace("[CHIM] AIProxy: IgnoreFriendlyHits SUCCESS")

    elseif cmdID == 120 ; InterruptCast
        akRef.InterruptCast()
        Debug.Trace("[CHIM] AIProxy: InterruptCast SUCCESS")

    elseif cmdID == 121 ; KnockAreaEffect
        float afMagnitude = AIAgentFunctions.jsonGetFloat("afMagnitude", jsonString)
        float afRadius = AIAgentFunctions.jsonGetFloat("afRadius", jsonString)
        akRef.KnockAreaEffect(afMagnitude, afRadius)
        Debug.Trace("[CHIM] AIProxy: KnockAreaEffect SUCCESS")

    elseif cmdID == 122 ; PushActorAway
        Actor akActorToPush = AIAgentFunctions.jsonGetActor("akActorToPush", jsonString)
        if !akActorToPush
            Debug.Trace("[CHIM] AIProxy: PushActorAway - invalid akActorToPush")
            return
        endif
        int aiKnockbackDamage = AIAgentFunctions.jsonGetInt("aiKnockbackDamage", jsonString)
        akRef.PushActorAway(akActorToPush, aiKnockbackDamage)
        Debug.Trace("[CHIM] AIProxy: PushActorAway SUCCESS")

    elseif cmdID == 123 ; SetActorOwner
        int actorBaseID = AIAgentFunctions.jsonGetFormId("akActorBase", jsonString)
        if actorBaseID == 0
            Debug.Trace("[CHIM] AIProxy: SetActorOwner - missing akActorBase")
            return
        endif
        ActorBase akActorBase = Game.GetFormEx(actorBaseID) as ActorBase
        if !akActorBase
            Debug.Trace("[CHIM] AIProxy: SetActorOwner - invalid ActorBase")
            return
        endif
        akRef.SetActorOwner(akActorBase)
        Debug.Trace("[CHIM] AIProxy: SetActorOwner SUCCESS")

    elseif cmdID == 124 ; SetFactionOwner
        int factionID = AIAgentFunctions.jsonGetFormId("akFaction", jsonString)
        if factionID == 0
            Debug.Trace("[CHIM] AIProxy: SetFactionOwner - missing akFaction")
            return
        endif
        Faction akFaction = Game.GetFormEx(factionID) as Faction
        if !akFaction
            Debug.Trace("[CHIM] AIProxy: SetFactionOwner - invalid Faction")
            return
        endif
        akRef.SetFactionOwner(akFaction)
        Debug.Trace("[CHIM] AIProxy: SetFactionOwner SUCCESS")

    elseif cmdID == 125 ; SetMotionType
        int aiMotionType = AIAgentFunctions.jsonGetInt("aiMotionType", jsonString)
        int abAllowActivate = AIAgentFunctions.jsonGetInt("abAllowActivate", jsonString)
        akRef.SetMotionType(aiMotionType, (abAllowActivate != 0))
        Debug.Trace("[CHIM] AIProxy: SetMotionType SUCCESS")

    elseif cmdID == 126 ; SetNoFavorAllowed
        int abNoFavor = AIAgentFunctions.jsonGetInt("abNoFavor", jsonString)
        akRef.SetNoFavorAllowed((abNoFavor != 0))
        Debug.Trace("[CHIM] AIProxy: SetNoFavorAllowed SUCCESS")

    elseif cmdID == 127 ; SetDestroyed
        int abDestroyed = AIAgentFunctions.jsonGetInt("abDestroyed", jsonString)
        akRef.SetDestroyed((abDestroyed != 0))
        Debug.Trace("[CHIM] AIProxy: SetDestroyed SUCCESS")

    elseif cmdID == 128 ; ClearDestruction
        akRef.ClearDestruction()
        Debug.Trace("[CHIM] AIProxy: ClearDestruction SUCCESS")

    elseif cmdID == 129 ; SendStealAlarm
        Actor akThief = AIAgentFunctions.jsonGetActor("akThief", jsonString)
        if !akThief
            Debug.Trace("[CHIM] AIProxy: SendStealAlarm - invalid akThief")
            return
        endif
        akRef.SendStealAlarm(akThief)
        Debug.Trace("[CHIM] AIProxy: SendStealAlarm SUCCESS")

    elseif cmdID == 130 ; AddKeyIfNeeded
        ObjectReference ObjectWithNeededKey = AIAgentFunctions.jsonGetReference("ObjectWithNeededKey", jsonString)
        if !ObjectWithNeededKey
            Debug.Trace("[CHIM] AIProxy: AddKeyIfNeeded - invalid ObjectWithNeededKey")
            return
        endif
        akRef.AddKeyIfNeeded(ObjectWithNeededKey)
        Debug.Trace("[CHIM] AIProxy: AddKeyIfNeeded SUCCESS")

    elseif cmdID == 131 ; PlaceAtMe
        int formID = AIAgentFunctions.jsonGetFormId("akFormToPlace", jsonString)
        if formID == 0
            Debug.Trace("[CHIM] AIProxy: PlaceAtMe - missing akFormToPlace")
            return
        endif
        Form akForm = Game.GetFormEx(formID)
        if !akForm
            Debug.Trace("[CHIM] AIProxy: PlaceAtMe - form not found")
            return
        endif
        int aiCount = AIAgentFunctions.jsonGetInt("aiCount", jsonString)
        if aiCount <= 0
            aiCount = 1
        endif
        int i = 0
        while i < aiCount
            akRef.PlaceAtMe(akForm, 1)
            i += 1
        endWhile
        Debug.Trace("[CHIM] AIProxy: PlaceAtMe SUCCESS")

    else
        Debug.Trace("[CHIM] AIProxy: UNKNOWN ObjectReference cmdID: " + cmdID)
    endif
EndFunction


; =============================================================================
; FORMLIST-SPECIFIC COMMAND HANDLER
; Handles FormList native functions (cmdID 200–299)
; Only non-getter, actionable functions included.
; =============================================================================
Function ExecuteCommandFormList(int cmdID, string jsonString) global
    Debug.Trace("[CHIM] AIProxy: ExecuteCommandFormList(cmdID=" + cmdID + ")")
    if cmdID <= 0 || !jsonString
        Debug.Trace("[CHIM] AIProxy: Invalid cmdID or null JSON")
        return
    endif

    FormList akFormList = AIAgentFunctions.jsonGetFormList("targetObjectFormId", jsonString)
    if !akFormList
        Debug.Trace("[CHIM] AIProxy: Target is not a valid FormList")
        return
    endif

    if cmdID == 200 ; AddForm
        int formID = AIAgentFunctions.jsonGetFormId("apForm", jsonString)
        if formID == 0
            Debug.Trace("[CHIM] AIProxy: AddForm - missing apForm")
            return
        endif
        Form apForm = Game.GetFormEx(formID)
        if !apForm
            Debug.Trace("[CHIM] AIProxy: AddForm - form not found: " + formID)
            return
        endif
        akFormList.AddForm(apForm)
        Debug.Trace("[CHIM] AIProxy: AddForm SUCCESS")

    elseif cmdID == 201 ; RemoveAddedForm
        int formID = AIAgentFunctions.jsonGetFormId("apForm", jsonString)
        if formID == 0
            Debug.Trace("[CHIM] AIProxy: RemoveAddedForm - missing apForm")
            return
        endif
        Form apForm = Game.GetFormEx(formID)
        if !apForm
            Debug.Trace("[CHIM] AIProxy: RemoveAddedForm - form not found: " + formID)
            return
        endif
        akFormList.RemoveAddedForm(apForm)
        Debug.Trace("[CHIM] AIProxy: RemoveAddedForm SUCCESS")

    elseif cmdID == 202 ; Revert
        akFormList.Revert()
        Debug.Trace("[CHIM] AIProxy: Revert SUCCESS")

    else
        Debug.Trace("[CHIM] AIProxy: UNKNOWN FormList cmdID: " + cmdID)
    endif
EndFunction


; =============================================================================
; EffectShader SPECIFIC COMMAND HANDLER
; Handles FormList native functions (cmdID 300–399)
; Only non-getter, actionable functions included.
; =============================================================================
Function ExecuteCommandEffectShader(int cmdID, string jsonString) global
    Debug.Trace("[CHIM] AIProxy: ExecuteCommandEffectShader(cmdID=" + cmdID + ")")
    if cmdID <= 0 || !jsonString
        Debug.Trace("[CHIM] AIProxy: Invalid cmdID or null JSON")
        return
    endif

    EffectShader akEffectShader = AIAgentFunctions.jsonGetEffectShader("targetObjectFormId", jsonString)
    if !akEffectShader
        Debug.Trace("[CHIM] AIProxy: Target is not a valid EffectShader")
        return
    endif

    if cmdID == 300 ; Play
        ObjectReference akObject = AIAgentFunctions.jsonGetReference("akObject", jsonString)
        if !akObject
            Debug.Trace("[CHIM] AIProxy: ExecuteCommandEffectShader -> Play - invalid akObject")
            return
        endif
		
		float afDuration=AIAgentFunctions.jsonGetFloat("afDuration", jsonString)
        if !afDuration
            Debug.Trace("[CHIM] AIProxy: ExecuteCommandEffectShader -> Play - invalid afDuration")
            return
        endif
		akEffectShader.Play(akObject,afDuration)
        Debug.Trace("[CHIM] AIProxy: ExecuteCommandEffectShader -> Play SUCCESS")

    elseif cmdID == 301 ; Stop
        ObjectReference akObject = AIAgentFunctions.jsonGetReference("akObject", jsonString)
        if !akObject
            Debug.Trace("[CHIM] AIProxy: ExecuteCommandEffectShader -> Stop - invalid akObject")
            return
        endif
        akEffectShader.Stop(akObject)
		Debug.Trace("[CHIM] AIProxy: ExecuteCommandEffectShader -> Stop SUCCESS")
    else
        Debug.Trace("[CHIM] AIProxy: UNKNOWN FormList cmdID: " + cmdID)
    endif
EndFunction

; =============================================================================
; ActorUtil SPECIFIC COMMAND HANDLER
; Handles FormList native functions (cmdID 400–499)
; Only non-getter, actionable functions included.
; =============================================================================
Function ExecuteCommandActorUtil(int cmdID, string jsonString) global
    Debug.Trace("[CHIM] AIProxy: ExecuteCommandActorUtil(cmdID=" + cmdID + ")")
    if cmdID <= 0 || !jsonString
        Debug.Trace("[CHIM] AIProxy: Invalid cmdID or null JSON")
        return
    endif

    if cmdID == 400 ; AddPackageOverride
        Actor akActor = AIAgentFunctions.jsonGetActor("akActor", jsonString)
        if !akActor
            Debug.Trace("[CHIM] AIProxy: ExecuteCommandActorUtil -> Play - invalid akObject")
            return
        endif
		
		int formID = AIAgentFunctions.jsonGetFormId("apForm", jsonString)
        if formID == 0
            Debug.Trace("[CHIM] AIProxy: ExecuteCommandActorUtil - missing apForm")
            return
        endif
        Package apPackage = Game.GetFormEx(formID) as Package
        if !apPackage
            Debug.Trace("[CHIM] AIProxy: ExecuteCommandActorUtil - form not found: " + formID)
            return
        endif
		
		int priority =  AIAgentFunctions.jsonGetInt("aiPriority", jsonString)
		
		ActorUtil.AddPackageOverride(akActor, apPackage, priority)
		Debug.Trace("[CHIM] AIProxy: ExecuteCommandActorUtil -> AddPackageOverride SUCCESS <"+apPackage.getFormId()+ "> on "+akActor.GetDisplayName())
		
	elseif cmdID == 401 ; SetLinkedRef
        Actor akActor = AIAgentFunctions.jsonGetActor("akActor", jsonString)
        if !akActor
            Debug.Trace("[CHIM] AIProxy: ExecuteCommandActorUtil -> Play - invalid akObject")
            return
        endif
		
		string asRef = AIAgentFunctions.jsonGetString("asRef", jsonString)
        
		
		if (asref == "door")
			ObjectReference reference = AIAgentFunctions.getNearestDoor()
			PO3_SKSEFunctions.SetLinkedRef(akActor,reference)
			Debug.Trace("[CHIM] AIProxy: ExecuteCommandActorUtil -> SetLinkedRef SUCCESS <"+reference.getFormId()+ "> on "+akActor.GetDisplayName())

		else
			Debug.Trace("[CHIM] AIProxy: UNKNOWN ExecuteCommandActorUtil SetLinkedRef refname: " + asref)
		endif
		
    else
        Debug.Trace("[CHIM] AIProxy: UNKNOWN ExecuteCommandActorUtil cmdID: " + cmdID)
    endif
EndFunction
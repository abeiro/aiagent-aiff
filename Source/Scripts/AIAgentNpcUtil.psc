Scriptname AIAgentNpcUtil 

; Declare the array with your values


; Function to get a random value
HeadPart function GetRandomFemaleBretonHairHeadPart() global
	int[] FemaleBretonHair = new int[21]
	FemaleBretonHair[0] = 0x000510f9
	FemaleBretonHair[1] = 0x00051104
	FemaleBretonHair[2] = 0x00051107
	FemaleBretonHair[3] = 0x0005110e
	FemaleBretonHair[4] = 0x00051146
	FemaleBretonHair[5] = 0x00051148
	FemaleBretonHair[6] = 0x0005114a
	FemaleBretonHair[7] = 0x00051172
	FemaleBretonHair[8] = 0x00051176
	FemaleBretonHair[9] = 0x00051177
	FemaleBretonHair[10] = 0x00051193
	FemaleBretonHair[11] = 0x000511a7
	FemaleBretonHair[12] = 0x000eaa70
	FemaleBretonHair[13] = 0x000eaa71
	FemaleBretonHair[14] = 0x000eaa72
	FemaleBretonHair[15] = 0x000eaa73
	FemaleBretonHair[16] = 0x000eaa74
	FemaleBretonHair[17] = 0x000eaa75
	FemaleBretonHair[18] = 0x000eaa76
	FemaleBretonHair[19] = 0x000eaa77
	FemaleBretonHair[20] = 0x00106b16

    int randomIndex = Utility.RandomInt(0, FemaleBretonHair.Length - 1) ; Random index within array bounds
    HeadPart hair=Game.GetForm(FemaleBretonHair[randomIndex]) as HeadPart
	return hair
	
endFunction

ActorBase Function getProperActorBase(Actor akActor) Global;return proper actor base for leveled and non-leveled actors	
	if akActor
		ActorBase akBase = akActor.GetBaseObject() as ActorBase
		ActorBase akLvlBase = akActor.GetLeveledActorBase()
		if (akLvlBase != akBase) ;should be true for all leveled actors
			return akLvlBase.GetTemplate()				
		else
			return akBase					
		EndIf
	endif
	return None
EndFunction


function CopyApearanceFromToComplex(Actor source, Actor dest) global

	ActorBase sourceBase=getProperActorBase(source);
	ActorBase destBase=getProperActorBase(dest);
	
	Quest rcQuest = Quest.getQuest("RaceMenu")
	RaceMenu rcMenu = rcQuest as RaceMenu

	If destBase && sourceBase
		Debug.Trace("[CHIM ADV] CopyApearanceFromToComplex start");
		int totalPresets = rcMenu.MAX_PRESETS
		int i = 0
		While i < totalPresets
			int preset = sourceBase.GetFacePreset(i)
			destBase.SetFacePreset(preset, i)
			i += 1
		EndWhile

		Debug.Trace("[CHIM ADV] Applied "+i+" presets ")
		
		int totalMorphs = rcMenu.MAX_MORPHS
		i = 0
		While i < totalMorphs
			float morph = sourceBase.GetFaceMorph(i)
			destBase.SetFaceMorph(morph, i)
			i += 1
		EndWhile
		
		Debug.Trace("[CHIM ADV] Applied "+i+" morphs ")

		HeadPart eyes = None
		HeadPart hair = None
		HeadPart facialHair = None
		HeadPart scar = None
		HeadPart brows = None

		int totalHeadParts = sourceBase.GetNumHeadParts()
		i = 0
		While i < totalHeadParts
			
			HeadPart current = sourceBase.GetNthHeadPart(i)
			if (current.GetType()==1)
				;
			else
				dest.ChangeHeadPart(current)
				Debug.Trace("[CHIM ADV] HeadPart("+i+"/"+totalHeadParts+") : "+AIAgentAIMind.DecToHex(current.GetFormId())+" "+current.GetName()+" "+current.GetType())
			endif
			i += 1
				
		EndWhile
		
		Debug.Trace("[CHIM ADV] Setting skin")
		destBase.SetSkin(sourceBase.GetSkin())
		destBase.SetSkinFar(sourceBase.GetSkinFar())

		Debug.Trace("[CHIM ADV] Setting hair")
		ColorForm hairColor = sourceBase.GetHairColor()
		destBase.SetHairColor(hairColor)
		rcMenu.SaveHair()
		ColorForm sourcecolor=PO3_SKSEFunctions.GetHairColor(source);
		if (dest.Is3DLoaded())
			PO3_SKSEFunctions.SetHairColor(dest,sourcecolor )
		endif
		

		if (dest.Is3DLoaded())
			Debug.Trace("[CHIM ADV] ResetActor3D")
			PO3_SKSEFunctions.ResetActor3D(dest, "PO3_ALPHA")
		else
			Debug.Trace("[CHIM ADV] CopyApearanceFromToComplex  ResetActor3D cancelled...will retry");
			Utility.wait(5)
			if (dest.Is3DLoaded())
				PO3_SKSEFunctions.ResetActor3D(dest, "PO3_ALPHA")
			else	
				Debug.Trace("[CHIM ADV] CopyApearanceFromToComplex  ResetActor3D cancelled");
				; Debug.Notification("[CHIM] spawned NPC ");
			EndIf
		endif
		
		
		Debug.Trace("[CHIM ADV] Setting face texture")
		TextureSet faceTXST = sourceBase.getFaceTextureSet()
		destBase.SetFaceTextureSet(faceTXST)
		
		destBase.SetVoiceType(sourceBase.GetVoiceType())
		;destBase.SetSkin(sourceBase.GetSkin())
		;destBase.SetSkinFar(sourceBase.GetSkinFar())
		
		float destWeight = destBase.getWeight()
		float sourceWeight = sourceBase.getWeight()
		dest.setWeight(sourceWeight)
		dest.updateWeight(sourceWeight / 100.0 - destWeight / 100.0)
		
		Debug.Trace("[CHIM ADV] Setting SetHeadPartTextureSet")
		if SKSE.GetPluginVersion("PapyrusExtender") >= 0
			PO3_SKSEFunctions.SetHairColor(dest, PO3_SKSEFunctions.GetHairColor(source))
			PO3_SKSEFunctions.SetSkinColor(dest, PO3_SKSEFunctions.GetSkinColor(source))
		
			If eyes
				TextureSet txst = PO3_SKSEFunctions.GetHeadPartTextureSet(source, 2)
				if txst
					PO3_SKSEFunctions.SetHeadPartTextureSet(dest, txst, 2)
				endIf
			Endif

			If hair
				TextureSet txst = PO3_SKSEFunctions.GetHeadPartTextureSet(source, 3)
				if txst
					PO3_SKSEFunctions.SetHeadPartTextureSet(dest, txst, 3)
				endIf
			Endif

			If facialHair
				TextureSet txst = PO3_SKSEFunctions.GetHeadPartTextureSet(source, 4)
				if txst
					PO3_SKSEFunctions.SetHeadPartTextureSet(dest, txst, 4)
				endIf
			Endif

			If scar
				TextureSet txst = PO3_SKSEFunctions.GetHeadPartTextureSet(source, 5)
				if txst
					PO3_SKSEFunctions.SetHeadPartTextureSet(dest, txst, 5)
				endIf
			Endif

			If brows
				TextureSet txst = PO3_SKSEFunctions.GetHeadPartTextureSet(source, 6)
				if txst
					PO3_SKSEFunctions.SetHeadPartTextureSet(dest, txst, 6)
				endIf
			Endif
		endIf
		
		Debug.Trace("[CHIM ADV] Setting PO3_TINT")
		PO3_SKSEFunctions.ResetActor3D(dest, "PO3_TINT")
		
		
		Debug.Trace("[CHIM ADV] Regenerated head")
		dest.RegenerateHead()
		Debug.Trace("[CHIM ADV] QueueNiNodeUpdate")
		dest.QueueNiNodeUpdate()
		
		; Will apply later
		StorageUtil.SetFormValue(dest, "CustomHairColor", sourcecolor)
		StorageUtil.SetFormValue(dest, "OriginalNPC", sourceBase)
		
		
	else
		Debug.Trace("CHIM ADV] CopyApearanceFromToComplex cancelled destBase,sourceBase: <"+source.GetFormID()+"> <"+dest.GetFormId()+">")
	Endif
endFunction

function FakeBrawl(Actor a,Actor b) global
	
		; Unarmed Combat
		; TO-DO restore statuses and weapons after fight
		a.SetNoBleedoutRecovery(true);
		b.SetNoBleedoutRecovery(true);
			
		AIAgentNpcUtil.RemoveAllWeapons(a);
		AIAgentNpcUtil.RemoveAllWeapons(b);
			
		CombatStyle CombatStyleA=AIAgentNpcUtil.getProperActorBase(a).GetCombatStyle();
		CombatStyle CombatStyleB=AIAgentNpcUtil.getProperActorBase(b).GetCombatStyle();
			
		CombatStyleA.SetUnarmedMult(100);
		CombatStyleB.SetUnarmedMult(100);
			
		Weapon unarmed=Game.GetForm(0x00001f4) as Weapon ; Unarmed
		a.EquipItem(unarmed,true,true)
		b.EquipItem(unarmed,true,true)
		
endFunction

function CopyApearanceFromTo(Actor source, Actor dest) global

	ActorBase sourceBase=getProperActorBase(source);
	ActorBase destBase=getProperActorBase(dest);
	
	Quest rcQuest = Quest.getQuest("RaceMenu")
	RaceMenu rcMenu = rcQuest as RaceMenu

	If destBase && sourceBase
		Debug.Trace("[CHIM ADV] CopyApearanceFromTo start");
		
		int totalHeadParts = sourceBase.GetNumHeadParts()
		int i = 0
		While i < totalHeadParts
			HeadPart current = sourceBase.GetNthHeadPart(i)
			if (current.GetType()==3)
				Debug.Trace("[CHIM ADV] Change Hair to"+current.GetPartName());
				dest.ChangeHeadPart(current)
			endif
			i += 1
		EndWhile
		
		ColorForm hairColor = sourceBase.GetHairColor()
		destBase.SetHairColor(hairColor)
	
		ColorForm sourcecolor=PO3_SKSEFunctions.GetHairColor(source);
		PO3_SKSEFunctions.SetHairColor(dest,sourcecolor)
	

		TextureSet txst = PO3_SKSEFunctions.GetHeadPartTextureSet(source, 3)
		if txst
			PO3_SKSEFunctions.SetHeadPartTextureSet(dest, txst, 3)
		endIf

	
		if (dest.Is3DLoaded())
			PO3_SKSEFunctions.ResetActor3D(dest, "PO3_ALPHA")
		else
			Debug.Trace("CHIM ADV]  ResetActor3D cancelled");
		endif
		
		
		dest.RegenerateHead()
		dest.QueueNiNodeUpdate()
		
	else
		Debug.Trace("CHIM ADV] CopyApearanceFromTo cancelled destBase,sourceBase: <"+source.GetFormID()+"> <"+dest.GetFormId()+">")
	Endif
endFunction


function RemoveAllWeapons(Actor npc)  global

	int iFormIndex = npc.GetNumItems()
	While(iFormIndex > 0 )
			iFormIndex -= 1
			Form objectForm = npc.GetNthForm(iFormIndex)
			int type=objectForm.GetType()
			if (type==41) ; weapon
				npc.RemoveItem(objectForm, npc.GetItemCount( objectForm ), true, None)
			endif
	EndWhile
endFunction

Function NpcPlayIdle(Actor ref,string animation) Global
	;Debug.SendAnimationEvent(ref,animation);Old way
	Quest AIAgentPapyrusFunctionsQuest = Game.GetFormFromFile(0x0093fc, "AIAgent.esp") as Quest 
	
	AIAgentPapyrusFunctionsQuest.OnAnimationEvent(ref,animation)

EndFunction

ObjectReference function findFurniture()
	
	Cell currentCell=Game.GetPlayer().GetParentCell();
	Int nRefs=currentCell.GetNumRefs(40);
	Int i = 0
	Float nearest =1000;
	ObjectReference candidate=None;
	
	while i < nRefs
		ObjectReference localRef = currentCell.GetNthRef(i, 40)
		;PO3_SKSEFunctions.GetFurnitureType(localRef as Furniture)
		if !localRef.IsFurnitureInUse()
			float distance = localRef.GetDistance(Game.GetPlayer())
			
			if distance < nearest
				candidate = localRef
				nearest = distance
			endif
		endif

		i += 1
	endwhile
	
	return candidate
endFunction


function sendAllActorsNames()
	if (false) 
		Debug.Notification("[CHIM] Sending all actors names");
		Form[] allActors=PO3_SKSEFunctions.GetAllForms(43)
		Debug.Trace("Total "+allActors.Length);
		int lengthA=allActors.Length
		int i=0;
		while i < lengthA
			Form j=allActors[i] as Form
			Debug.Trace("Adding NPC "+j.GetName());
			AIAgentFunctions.logMessage(j.GetName(),"util_npcname")
			i=i+1
		endwhile
		return
	endif
endFunction


bool Function  FindItemAvoidingRenaming(ObjectReference akRef) global
    If akRef == None
        ;Debug.Trace("[REALNAMES - CHIM] No reference provided.")
        Return false
    EndIf

    ; SKSE native function - returns all items in the ref's inventory
    Form[] allItems = PO3_SKSEFunctions.AddAllItemsToArray(akRef, True, False, False)

    If allItems == None
        ;Debug.Trace("[REALNAMES - CHIM] No items found.")
        Return false
    EndIf

    Int count = allItems.Length
    ;Debug.Trace("[REALNAMES - CHIM] Found " + count + " total item(s) in inventory.")

    Int i = 0
    While i < count
        Form item = allItems[i]
        If item
            String itemName = item.GetName()
            If itemName != "" && itemName == "Scroll of Identity"
                Debug.Trace("[REALNAMES - CHIM] Found item: " + itemName + " (FormID: " + item.GetFormID() + ")")
				return true
            EndIf
        EndIf
        i += 1
    EndWhile
	return false
EndFunction


bool function MakeFollower(Actor akTarget) global

	Faction PotentialFollowerFaction = Game.GetForm(0x0005c84d) as Faction
	Faction CurrentFollowerFaction = Game.GetForm(0x0005c84e) as Faction 

	akTarget.AddToFaction(PotentialFollowerFaction)
    akTarget.SetFactionRank(PotentialFollowerFaction, 0)

    ; Make them your active follower
    akTarget.AddToFaction(CurrentFollowerFaction)
    akTarget.SetFactionRank(CurrentFollowerFaction, 1)

	Quest nwsFF = (Game.GetFormFromFile(0x0000434F, "nwsFollowerFramework.esp") as Quest)
    ; Tell the follower quest to follow the player
	if (nwsFF)
		(nwsFF as nwsFollowerControllerScript).RecruitAction(akTarget)
	endif
	;(nwsFF as nwsFollowerControllerScript).FollowerFollowMe(akTarget, 1)


    ;Debug.Notification(akTarget.GetDisplayName() + " is now your follower.")
endFunction


;Experiments
bool function PlaceMusicCam(Actor npc,Actor singer,int mode, float power,string animation) global


	;ImageSpaceModifier FadeToBlack = Game.GetForm(0x000f756d) as ImageSpaceModifier
	;ImageSpaceModifier FadeFromBlack = Game.GetForm(0x000f756f) as ImageSpaceModifier
	;fadeToBlack.Apply() ; fade in 1 second
	;Game.FadeOutGame(False,True,50, 1)
	
	;EffectShader shader=Game.GetForm(0x000d33a0)  as EffectShader	
	float rndEn=Utility.RandomFloat(-50.0, 50.0)
	if (mode == 1)
		AIAgentAIMind.PlaceCam(npc,1,true,rndEn);
		
		NpcPlayIdle(npc,"IdleLuteStart")
		if (power>100)
			npc.SetLookAt(Game.GetPlayer());
		else
			npc.SetLookAt(singer);
		endif
		NpcPlayIdle(singer, "IdleForceDefaultState")	
	elseif (mode == 2)
		AIAgentAIMind.PlaceCam(npc,1,true,rndEn)
	
	
		NpcPlayIdle(npc,"IdleDrumStart")
		if (power>140)
			npc.SetLookAt(Game.GetPlayer());
		else
			npc.SetLookAt(singer);
		endif
		NpcPlayIdle(singer, "IdleForceDefaultState")	
	elseif (mode == 3)
		AIAgentAIMind.PlaceCam(npc,1,true,rndEn);
		
		NpcPlayIdle(npc,"IdleLuteStart")
		if (power>100)
			npc.SetLookAt(Game.GetPlayer());
		else
			npc.SetLookAt(singer);
		endif
		NpcPlayIdle(singer, "IdleForceDefaultState")	
	elseif (mode == 4)
		NpcPlayIdle(npc,"IdleLuteStart")	
		if (power>100)
			npc.SetLookAt(Game.GetPlayer());
		else
			npc.SetLookAt(singer);
		endif
		NpcPlayIdle(singer, "IdleForceDefaultState")	
		
	elseif (mode == 0)
		; When singer sings and more than 4 seconds ellapsed
		;AIAgentAIMind.PlaceCam(Game.GetPlayer(),1,true,rndEn);
		;singer.SetLookAt(Game.GetPlayer());
		if (power>5)
			NpcPlayIdle(singer, animation)	
		endif;
		;singer.ClearLookAt()
		int rndEnFov=Utility.RandomInt(70, 120)
		Consoleutil.ExecuteCommand("fov "+rndEnFov);	
	
		;AIAgentAIMind.PlaceCam(Game.GetPlayer(),1,true,rndEn);
		;NpcPlayIdle(npc, "IdleForceDefaultState")	
	endif


	
	
	;Game.FadeOutGame(False,True,0.1, 0.1)
	;FadeToBlack.PopTo(FadeFromBlack)		

endFunction

function MoveBehind(Actor akTarget, Actor akActorRef, int scattering) global

	float distanceOffset = 250.0
	float sideSpacing = 90.0 ; how far apart each NPC spreads

	float angleZ = akActorRef.GetAngleZ()

	; Forward vector
	float forwardX = Math.Sin(angleZ)
	float forwardY = Math.Cos(angleZ)

	; Right vector
	float rightX = Math.Cos(angleZ)
	float rightY = -Math.Sin(angleZ)

	; --- Behind offset ---
	float baseX = -distanceOffset * forwardX
	float baseY = -distanceOffset * forwardY

	; --- Scattering logic ---
	; Convert 1,2,3 into -1,0,+1 pattern
	float sideIndex = scattering - 2

	float sideX = sideIndex * sideSpacing * rightX
	float sideY = sideIndex * sideSpacing * rightY

	float finalX = baseX + sideX
	float finalY = baseY + sideY

	akTarget.MoveTo(akActorRef, finalX, finalY, akActorRef.GetHeight() - 20.0)

endFunction

bool function SwordsAndNirnsFrontman(Actor singer, float power = 1.0,int lyricsSize,string emotion) global
	
	

	return true

endFunction

bool function StartMusicScene(Actor singer,string songname) global

	Actor drummer;
	Actor bass;
	Actor guitar1;
	Actor guitar2;
	
	
	ActorBase baseG1  =Game.GetFormFromFile(0x5901, "AIAgentSNN.esp") as ActorBase 
	ActorBase baseD  =Game.GetFormFromFile(0x5902, "AIAgentSNN.esp") as ActorBase 
	ActorBase baseB  =Game.GetFormFromFile(0x5903, "AIAgentSNN.esp") as ActorBase 
	ActorBase baseG2  =Game.GetFormFromFile(0x5904, "AIAgentSNN.esp") as ActorBase 
	
	Spell lightSpell = Game.GetForm(0x00043324) as Spell 
	Spell fireSpell = Game.GetForm(0x0005dd60) as Spell 
	MusicType silence =  Game.GetForm(0x0001ba72) as MusicType;	30 seconds silence
	
	silence.add();
	;singer.AddSpell(lightSpell, false)
	lightSpell.Cast(singer, singer)
	fireSpell.Cast(singer, singer)

	;AIAgentAIMind.PlaceCam(Game.GetPlayer(),1,true);
	
	drummer=singer.PlaceAtMe(baseD,1,false,true) as Actor
	bass=singer.PlaceAtMe(baseB,1,false,true) as Actor
	guitar1=singer.PlaceAtMe(baseG1,1,false,true) as Actor
	guitar2=singer.PlaceAtMe(baseG2,1,false,true) as Actor
	
	drummer.setDisplayName("Morth Sorum")
	bass.setDisplayName("Dov McKagarn")
	guitar1.setDisplayName("Skaar Slashborn")
	guitar2.setDisplayName("Izran Stalhrim")
	
	Package doNothing = Game.GetForm(0x654e2) as Package ; Package Travelto
	ActorUtil.AddPackageOverride(singer, doNothing,99)
	ActorUtil.AddPackageOverride(drummer, doNothing,99)
	ActorUtil.AddPackageOverride(bass, doNothing,99)
	ActorUtil.AddPackageOverride(guitar1, doNothing,99)
	ActorUtil.AddPackageOverride(guitar2, doNothing,99)
	
	
	
	StorageUtil.SetStringValue(drummer,"forced_name",drummer.GetDisplayName())
	StorageUtil.SetStringValue(bass,"forced_name",drummer.GetDisplayName())
	StorageUtil.SetStringValue(guitar1,"forced_name",drummer.GetDisplayName())
	StorageUtil.SetStringValue(guitar2,"forced_name",drummer.GetDisplayName())
		
	drummer.EvaluatePackage()
	bass.EvaluatePackage()
	guitar1.EvaluatePackage()
	guitar2.EvaluatePackage()
	
	MoveBehind(drummer,singer,1)
	MoveBehind(bass,singer,2)
	MoveBehind(guitar1,singer,3)
	MoveBehind(guitar2,singer,4)
	
	drummer.Enable(true)
	drummer.SetDontMove(false)
	drummer.SetScale(1.05)
	AIAgentFunctions.setDrivenByAIA(drummer,false)
	bass.Enable(true)
	bass.SetDontMove(false)
	bass.SetScale(1.1)
	AIAgentFunctions.setDrivenByAIA(bass,false)
	guitar1.Enable(true)
	guitar1.SetDontMove(false)
	guitar1.SetScale(1)
	AIAgentFunctions.setDrivenByAIA(guitar1,false)
	guitar2.Enable(true)
	guitar2.SetDontMove(false)
	guitar2.SetScale(0.99)
	AIAgentFunctions.setDrivenByAIA(guitar2,false)
	
		
	Utility.wait(1)
	NpcPlayIdle(drummer,"IdleDrumStart")
	NpcPlayIdle(guitar1,"IdleLuteStart")
	NpcPlayIdle(guitar2,"IdleLuteStart")
	NpcPlayIdle(bass,"IdleLuteStart")	
	NpcPlayIdle(singer, "IdleRitualSkull3")
	

	AIAgentAIMind.PlaceCam(singer,1,true);
	
	Utility.wait(1)
	AIAgentFunctions.startMusicScene(songname,singer.GetDisplayName())
endfunction

bool function SwordsAndNirnsStop(Actor singer) global

	
	Actor drummer = AIAgentFunctions.getAgentByName("Morth Sorum")
	Actor bass = AIAgentFunctions.getAgentByName("Dov McKagarn")
	Actor guitar1 = AIAgentFunctions.getAgentByName("Skaar Slashborn");
	Actor guitar2 = AIAgentFunctions.getAgentByName("Izran Stalhrim");
	AIAgentFunctions.setLocked(0,singer.GetDisplayName())
	NpcPlayIdle(singer, "IdleForceDefaultState")

	
	;Spell fireSpell = Game.GetForm(0x0005dd60) as Spell 
	;fireSpell.Cast(drummer )


	AIAgentAIMind.Despawn(drummer)
	AIAgentAIMind.Despawn(bass)
	AIAgentAIMind.Despawn(guitar1)
	AIAgentAIMind.Despawn(guitar2)
	Utility.wait(1)
	AIAgentFunctions.removeAgentByName("Morth Sorum")
	AIAgentFunctions.removeAgentByName("Dov McKagarn")
	AIAgentFunctions.removeAgentByName("Skaar Slashborn")
	AIAgentFunctions.removeAgentByName("Izran Stalhrim")	

	singer.ClearLookAt();
	Consoleutil.ExecuteCommand("fov ");
	AIAgentAIMind.resetCam()

endfunction
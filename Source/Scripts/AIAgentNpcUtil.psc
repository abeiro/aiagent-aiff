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
		Debug.Trace("[CHIM ADV] CopyApearanceFromTo start");
		int totalPresets = rcMenu.MAX_PRESETS
		int i = 0
		While i < totalPresets
			int preset = sourceBase.GetFacePreset(i)
			destBase.SetFacePreset(preset, i)
			i += 1
		EndWhile

		int totalMorphs = rcMenu.MAX_MORPHS
		i = 0
		While i < totalMorphs
			float morph = sourceBase.GetFaceMorph(i)
			destBase.SetFaceMorph(morph, i)
			i += 1
		EndWhile

		HeadPart eyes = None
		HeadPart hair = None
		HeadPart facialHair = None
		HeadPart scar = None
		HeadPart brows = None

		int totalHeadParts = sourceBase.GetNumHeadParts()
		i = 0
		While i < totalHeadParts
			HeadPart current = sourceBase.GetNthHeadPart(i)
			dest.ChangeHeadPart(current)
			i += 1
		EndWhile
		
		destBase.SetSkin(sourceBase.GetSkin())
		destBase.SetSkinFar(sourceBase.GetSkinFar())

		ColorForm hairColor = sourceBase.GetHairColor()
		destBase.SetHairColor(hairColor)
	
		ColorForm sourcecolor=PO3_SKSEFunctions.GetHairColor(source);
		if (dest.Is3DLoaded())
			PO3_SKSEFunctions.SetHairColor(dest,sourcecolor )
		endif
		
		; Will apply later
		StorageUtil.SetFormValue(dest, "CustomHairColor", sourcecolor)
		

		TextureSet txst = PO3_SKSEFunctions.GetHeadPartTextureSet(source, 3)
		if txst
			PO3_SKSEFunctions.SetHeadPartTextureSet(dest, txst, 3)
		endIf

	
		if (dest.Is3DLoaded())
			PO3_SKSEFunctions.ResetActor3D(dest, "PO3_ALPHA")
		else
			Debug.Trace("CHIM ADV]  ResetActor3D cancelled");
		endif
		
		destBase.SetVoiceType(sourceBase.GetVoiceType())
		destBase.SetSkin(sourceBase.GetSkin())
		destBase.SetSkinFar(sourceBase.GetSkinFar())
		
		float destWeight = destBase.getWeight()
		float sourceWeight = sourceBase.getWeight()
		dest.setWeight(sourceWeight)
		dest.updateWeight(sourceWeight / 100.0 - destWeight / 100.0)
		
		dest.RegenerateHead()
		dest.QueueNiNodeUpdate()
		
	else
		Debug.Trace("CHIM ADV] CopyApearanceFromTo cancelled");
	Endif
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
		Debug.Trace("CHIM ADV] CopyApearanceFromTo cancelled");
	Endif
endFunction

Function NpcPlayIdle(Actor ref,string animation) Global
	Debug.SendAnimationEvent(ref,animation)
EndFunction
Scriptname AIAgentPlayerScript extends actor


Event OnPlayerFastTravelEnd(float afTravelGameTimeHours)

	Utility.wait(5);Give time to NPCs around to load
	AIAgentFunctions.logMessage("", "location")
	AIAgentFunctions.logMessage("The Narrator: The party has been travelling for "+afTravelGameTimeHours+" hours.", "infoaction")

	

EndEvent

Bool Function IsActorNakedVanilla(Actor who)
    Return !(who.WornHasKeyword(Game.GetFormFromFile(0x06C0EC, "Skyrim.esm") as Keyword) || who.WornHasKeyword(Game.GetFormFromFile(0x0A8657, "Skyrim.esm") as Keyword))
EndFunction

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	if (IsActorNakedVanilla(Game.GetPlayer()))
		AIAgentFunctions.logMessage("player_naked@1","setconf")
	else
		AIAgentFunctions.logMessage("player_naked@0", "setconf")
	endIf
endEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	if (IsActorNakedVanilla(Game.GetPlayer()))
		AIAgentFunctions.logMessage("player_naked@1","setconf")
	else
		AIAgentFunctions.logMessage("player_naked@0", "setconf")
	endIf
endEvent

Event OnLocationChange(Location oldLoc,Location newLoc)
	Location currParentLvl1=PO3_SKSEFunctions.GetParentLocation(newLoc)
	Location currParentLvl2=PO3_SKSEFunctions.GetParentLocation(currParentLvl1)
	
	if (currParentLvl2 && currParentLvl2.getName() != "Tamriel" )
		AIAgentFunctions.logMessage(currParentLvl2.getName(), "region")
	elseif (currParentLvl1)
		AIAgentFunctions.logMessage(currParentLvl1.getName(), "region")
	elseif newLoc
		AIAgentFunctions.logMessage(newLoc.getName(), "region")
	endif;
endEvent

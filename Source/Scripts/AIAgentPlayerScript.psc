Scriptname AIAgentPlayerScript extends actor


Event OnPlayerFastTravelEnd(float afTravelGameTimeHours)

	Utility.wait(5);Give time to NPCs around to load
	AIAgentFunctions.logMessage("", "location")
	AIAgentFunctions.logMessage("The Narrator: The party has been travelling for "+afTravelGameTimeHours+" hours.", "infoaction")

	

EndEvent
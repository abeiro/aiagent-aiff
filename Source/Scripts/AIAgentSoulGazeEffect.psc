Scriptname AIAgentSoulGazeEffect 


function Soulgaze(int mode) global
	
	String hints="";
	
	int customMode=mode
	
	
	if ((AIAgentFunctions.isGameVR()==1) || customMode==0)
		
		Consoleutil.ExecuteCommand("tm");
		Utility.wait(1);
		AIAgentFunctions.shotAndUpload(hints,0)
		Consoleutil.ExecuteCommand("tm");
		
	else
		
		;Game.ForceFirstPerson();
		
		
		; Try to guess wich actors are in camera
		Actor[] actors = MiscUtil.ScanCellNPCs(Game.GetPlayer())
		; remove player actor from the list
		actors = PapyrusUtil.RemoveActor(actors,Game.GetPlayer())
		int i = actors.length - 1
		Actor actorAtIndex = None

		; iterating reversed as we modify the array
		while i>=0
			actorAtIndex = actors[i]
			if (Game.GetPlayer().HasLOS(actorAtIndex))
				hints=hints+actorAtIndex.GetDisplayName()+",";
			endif
			i -= 1
		endwhile
		
		Consoleutil.ExecuteCommand("tm");
		AIAgentFunctions.shotAndUpload(hints,1)
		Utility.wait(1);
		Game.ShakeCamera();
		Consoleutil.ExecuteCommand("tm");
	endif 
endFunction

function SendProfilePicture(int mode) global
	
	String hints="";
	
	int customMode=mode
	
	
	if ((AIAgentFunctions.isGameVR()==1) || customMode==0)
		
		Consoleutil.ExecuteCommand("tm");
		Consoleutil.ExecuteCommand("fov 60");
		Consoleutil.ExecuteCommand("tfc");
		Utility.wait(1);
		AIAgentFunctions.shotAndUpload(hints,2)
		Utility.wait(1);
		Consoleutil.ExecuteCommand("tfc");
		Consoleutil.ExecuteCommand("tm");
		
	else
		
		;Game.ForceFirstPerson();
		
		
		; Try to guess wich actors are in camera
		Actor[] actors = MiscUtil.ScanCellNPCs(Game.GetPlayer())
		; remove player actor from the list
		actors = PapyrusUtil.RemoveActor(actors,Game.GetPlayer())
		int i = actors.length - 1
		Actor actorAtIndex = None

		; iterating reversed as we modify the array
		while i>=0
			actorAtIndex = actors[i]
			if (Game.GetPlayer().HasLOS(actorAtIndex))
				hints=hints+actorAtIndex.GetDisplayName()+",";
			endif
			i -= 1
		endwhile
		
		Consoleutil.ExecuteCommand("tm");
		Consoleutil.ExecuteCommand("fov 60");
		Consoleutil.ExecuteCommand("tfc");
		Utility.wait(1);
		AIAgentFunctions.shotAndUpload(hints,3)
		Utility.wait(1);
		Consoleutil.ExecuteCommand("tfc");
		Consoleutil.ExecuteCommand("tm");
		
	endif 
endFunction
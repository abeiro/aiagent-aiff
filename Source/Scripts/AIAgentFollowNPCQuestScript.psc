Scriptname AIAgentFollowNPCQuestScript extends Quest Hidden 

Actor Property leader Auto
float Property originalSpeed auto

bool		following = false

Function startFollowing(Actor cLeader)

	leader = cLeader
	following  = true
	Debug.Trace("[CHIM] AIAgentFollowNPCQuestScript START: "+leader.GetDisplayName());
	if (!originalSpeed)
		originalSpeed = Game.GetPlayer().GetActorValue("SpeedMult")	
	endif
	
	RegisterForSingleUpdate(1.0)
	
endfunction


Function stopFollowing(Actor cLeader)

	Debug.Trace("[CHIM] Restoring speed "+originalSpeed)
	Game.GetPlayer().SetActorValue("SpeedMult", originalSpeed)	
					
	UnregisterForUpdate()
	following = false
	leader = None 
	
	Debug.Trace("[CHIM] AIAgentFollowNPCQuestScript STOP: "+leader.GetDisplayName());
endfunction

Event OnUpdate()
    ;Debug.Notification("Updating...")
	If(following)
		
		float offsetCustom = Game.GetPlayer().GetDistance(leader)
		
		while offsetCustom > 256
		
			if (following)
		
				if (offsetCustom > 2048)
					Game.GetPlayer().SetActorValue("SpeedMult", 550)
				elseif (offsetCustom > 1024)
					Game.GetPlayer().SetActorValue("SpeedMult", 450)	
				elseif (offsetCustom > 512)
					Game.GetPlayer().SetActorValue("SpeedMult", 550)	
				else
					Game.GetPlayer().SetActorValue("SpeedMult", 250)		
				endif

				Game.GetPlayer().ModActorValue("CarryWeight", 0.1) ; Confirm SpeedMult change
				
				Debug.Trace("[CHIM] PathToReference START: "+leader.GetDisplayName() + ",distance:"+offsetCustom);
				Game.GetPlayer().PathToReference(leader, 1)
				offsetCustom = Game.GetPlayer().GetDistance(leader)
				Debug.Trace("[CHIM] PathToReference END: "+leader.GetDisplayName() + ",distance:"+offsetCustom);
			else
				offsetCustom = 0 
			endif
			
		endwhile
		Game.GetPlayer().SetActorValue("SpeedMult", originalSpeed)	
		if (following)
			RegisterForSingleUpdate(3.0)
		endif 
	EndIf	

Endevent
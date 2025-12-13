Scriptname AIAgentAIMind 

import AIAgentNpcUtil
		
Actor herika
Keyword property ActorTypeNPC auto
Actor lastTarget

;FavorDialogueScript Property DialogueFavorGeneric Auto


function Test() global

Debug.Notification("Ok");

endFunction



function ResetPackages(Actor npc) global

	;npc.EnableAI(false) 

	Package TraveltoPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Package AttackPackage = Game.GetFormFromFile(0x01B6C2 , "AIAgent.esp") as Package ; Package AttackPackage
	Package FollowPackage = Game.GetFormFromFile(0x01BC25, "AIAgent.esp") as Package 
	Package SeatPackage = Game.GetFormFromFile(0x01C6E9, "AIAgent.esp") as Package ; Package SeatPackage
	Package MoveToPackage = Game.GetFormFromFile(0x01C6E8, "AIAgent.esp") as Package ; Package MoveToTarget
	Package WaitPackage = Game.GetFormFromFile(0x02021F, "AIAgent.esp") as Package ; Package MoveToTarget
	Package FollowPlayerPackage = Game.GetFormFromFile(0x2226d,"AIAgent.esp") as Package		; FollowPlayerPackage
	Package SandboxPackage = Game.GetFormFromFile(0x20ce2,"AIAgent.esp") as Package		; Package sandboxPackage 
	Package doNothing = Game.GetForm(0x654e2) as Package ; Package doNothing

	Keyword MoveTargetKw = Game.GetFormFromFile(0x021245,"AIAgent.esp") as Keyword	;

	
	
	ActorUtil.RemovePackageOverride(npc, TraveltoPackage)
	ActorUtil.RemovePackageOverride(npc, AttackPackage)
	ActorUtil.RemovePackageOverride(npc, FollowPackage)
	ActorUtil.RemovePackageOverride(npc, SeatPackage)
	ActorUtil.RemovePackageOverride(npc, MoveToPackage)
	ActorUtil.RemovePackageOverride(npc, WaitPackage)
	ActorUtil.RemovePackageOverride(npc, FollowPlayerPackage)
	ActorUtil.RemovePackageOverride(npc, SandboxPackage)
	ActorUtil.RemovePackageOverride(npc, doNothing)
	;ActorUtil.ClearPackageOverride(npc)
	
	PO3_SKSEFunctions.SetLinkedRef(npc,None,MoveTargetKw)
	
	npc.EvaluatePackage()
	
	SheatheWeapon(npc);
	
	AIAgentFunctions.setLocked(0,npc.GetDisplayName())
	AIAgentFunctions.setAnimationBusy(0,npc.GetDisplayName())
	;npc.EnableAI(true) 


endFunction

function PlayerFollowStart() global



endFunction

function MoveToTarget(Actor npc, ObjectReference akTarget, int intent) global
	
	ResetPackages(npc);
	Package MoveToPackage = Game.GetFormFromFile(0x01C6E8, "AIAgent.esp") as Package ; Package MoveToTarget
	Faction MoveToFaction=Game.GetFormFromFile(0x01A69B, "AIAgent.esp") as Faction ; Faction MoveToTarget
	Keyword MoveTargetKw = Game.GetFormFromFile(0x021245,"AIAgent.esp") as Keyword	;
	Faction SandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	
	npc.RemoveFromFaction(FollowFaction)
	npc.RemoveFromFaction(SandboxFaction)
	
	npc.SetFactionRank(MoveToFaction,1)
	
	StorageUtil.SetFormValue(npc, "LastMoveToLocation",akTarget);
	StorageUtil.SetIntValue(npc, "MoveToTargetIntent",intent);
	; 1- Give
	; 2- Trade
	; 3- Spawn
	
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget,MoveTargetKw)
	ActorUtil.AddPackageOverride(npc, MoveToPackage, 100, 0)
	npc.EvaluatePackage()
	;Debug.Notification("[CHIM] "+npc.GetDisplayName()+" is moving to "+akTarget.GetDisplayName())
	Debug.Trace("[CHIM] MoveToTarget "+npc.GetDisplayName()+" is moving to "+akTarget.GetDisplayName())
	AIAgentFunctions.logMessageForActor("started_moving@"+akTarget.GetDisplayName(),"status_msg",npc.GetDisplayName())

endFunction

function MoveToTargetEnd(Actor npc) global

	;Debug.Notification("[CHIM] End of move: "+npc.GetDisplayName())	
	

	if (npc.GetParentCell()==Game.GetPlayer().GetParentCell())
		AIAgentFunctions.logMessageForActor("reached_destination_player@"+npc.GetDisplayName(),"status_msg",npc.GetDisplayName())
	else
		AIAgentFunctions.logMessageForActor("reached_destination@"+npc.GetDisplayName(),"status_msg",npc.GetDisplayName())
	endif
	
	ObjectReference destination=StorageUtil.GetFormValue(npc, "LastMoveToLocation") as ObjectReference;
	int intent=StorageUtil.GetIntValue(npc, "MoveToTargetIntent") as int;
	
	
	if (destination)
		Form dest=destination.GetBaseObject()
		if (dest.GetType()==43) 
			Actor destinationActor=destination as Actor
			npc.KeepOffsetFromActor(destinationActor, 0.0, 0.0, 5.0, afFollowRadius = 32.0);Move it next to it
			Utility.Wait(3);
			npc.ClearKeepOffsetFromActor()
			if (destinationActor.IsDead()); Inspecting a dead body
				Debug.Notification("[CHIM] "+npc.GetDisplayName()+ " inspects "+destinationActor.getDisplayName())
				LookAt(npc,destinationActor)
				Debug.SendAnimationEvent(npc,"IdleKneeling")
				Utility.wait(3)
				Debug.SendAnimationEvent(npc,"IdleForceDefaultState")
			endif
			if (intent==1);Give
				Debug.trace("[CHIM] MoveToTargetEnd performing animation IdleGive");
				LookAt(npc,destinationActor)
				Debug.SendAnimationEvent(npc,"IdleGive")
				Utility.wait(1)
				
				; Actually transfer the item using stored Form ID
				int formID = StorageUtil.GetIntValue(npc, "PendingGiveFormID", 0)
				int itemAmount = StorageUtil.GetIntValue(npc, "PendingGiveAmount", 0)
				string itemName = StorageUtil.GetStringValue(npc, "PendingGiveItem", "")
				
				if (formID > 0 && itemAmount > 0)
					Debug.Trace("[CHIM] Transferring "+itemAmount+" "+itemName+" (FormID:"+formID+") from "+npc.GetDisplayName()+" to "+destinationActor.GetDisplayName())
					
					; Get the Form by ID
					Form itemForm = Game.GetForm(formID)
					if (itemForm)
						; Use MoveInventoryItem for proper transfer with confirmation for gold
						MoveInventoryItem(npc, destinationActor, itemForm, itemAmount, itemName)
						
						Debug.Notification(npc.GetDisplayName()+" gave "+itemAmount+" "+itemName+" to "+destinationActor.GetDisplayName())
						AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" gave "+itemAmount+" "+itemName+" to "+destinationActor.GetDisplayName(),"itemtransfer",npc.GetDisplayName())
					else
						Debug.Trace("[CHIM] ERROR: Could not find Form with ID "+formID)
					endif
					
					; Clear the pending transfer data
					StorageUtil.SetIntValue(npc, "PendingGiveFormID", 0)
					StorageUtil.SetIntValue(npc, "PendingGiveAmount", 0)
					StorageUtil.SetStringValue(npc, "PendingGiveItem", "")
				endif
			endif
			
			if (intent==2);Trade
				Debug.trace("[CHIM] MoveToTargetEnd performing animation IdleGive2");
				LookAt(npc,destinationActor)
				Debug.SendAnimationEvent(npc,"IdleGive")
				Debug.SendAnimationEvent(destinationActor,"IdleGive")
				Utility.wait(1)
			endif
			
		if (intent==3);spawn
			Debug.trace("[CHIM] MoveToTargetEnd , introducing spawned NPC");
			AIAgentFunctions.requestMessageForActor("The Narrator:"+npc.GetDisplayName()+" appears in scene, directly pointing to its goal.","instruction",npc.GetDisplayName())
			stayAtPlace(npc,0);
		endif
		
		Debug.Trace("[CHIM] MoveToTargetEnd: "+npc.GetDisplayName()+". Move destination was "+destinationActor.GetDisplayName()+" "+destinationActor.GetFormId()+" "+destinationActor.GetType())
		
	else
		; destination is not an Actor - could be an item pickup
		if (intent==4);pickup
			; Get the pending pickup data
			string itemName
			itemName = StorageUtil.GetStringValue(npc, "PendingPickupItem", "")
			
			if (itemName != "")
				; Play pickup animation
				Debug.SendAnimationEvent(npc, "IdlePickup")
				Utility.Wait(0.5)
				
				; Activate the item to pick it up
				ObjectReference itemRef
				itemRef = destination as ObjectReference
				if (itemRef)
					npc.Activate(itemRef)
					
					; Wait a moment for the pickup to process
					Utility.Wait(0.5)
					
					; Refresh the NPC's inventory so they know what they picked up
					Debug.TraceUser("ChimHTTPSender", "AIAgentRefreshInventory|"+npc.GetFormID())
					
					; Notify server of the pickup
					int currentTime
					currentTime = Utility.GetCurrentRealTime() as int
					int gameTime
					gameTime = Utility.GetCurrentGameTime() as int
					string logMessage
					logMessage = "itempickup|"+currentTime+"|"+gameTime+"|"+npc.GetDisplayName()+" picked up "+itemName
					Debug.TraceUser("ChimHTTPSender", logMessage)
					AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" picked up "+itemName,"itempickup",npc.GetDisplayName())
					
					Debug.Notification(npc.GetDisplayName()+" picked up "+itemName)
				endif
				
				; Clear the pending pickup data
				StorageUtil.SetStringValue(npc, "PendingPickupItem", "")
			endif
		endif
	endif
endif
	
	StorageUtil.SetFormValue(npc, "LastMoveToLocation",None);
	StorageUtil.SetIntValue(npc, "MoveToTargetIntent",0);
	
	
	Utility.Wait(3);
	Package MoveToPackage = Game.GetFormFromFile(0x01C6E8, "AIAgent.esp") as Package ; Package MoveToTarget
	Faction MoveToFaction=Game.GetFormFromFile(0x01A69B, "AIAgent.esp") as Faction ; Faction MoveToTarget
	Keyword MoveTargetKw = Game.GetFormFromFile(0x21245,"AIAgent.esp") as Keyword	; // Psijic Monk Outfit
	
	npc.RemoveFromFaction(MoveToFaction)
	ActorUtil.RemovePackageOverride(npc, MoveToPackage)
	PO3_SKSEFunctions.SetLinkedRef(npc,None,MoveTargetKw)
	npc.EvaluatePackage()
	
	AIAgentFunctions.commandEndedForActor("MoveTo",npc.GetDisplayName())

	;string taskid = JDB.solveStr(".aiff.currentTaskId");
	
	if (intent==3)
		stayAtPlace(npc,0)
	Endif
	
	;AIAgentFunctions.requestMessageForActor(npc.GetDisplayName()+" appears in scene.Should surroudings, maybe looking for someone/something","welcome",npc.GetDisplayName())
	Debug.Trace("[CHIM] MoveToTargetEnd End of move: "+npc.GetDisplayName())	
	

endFunction

function TakeASeat(Actor npc, ObjectReference akTarget) global
	
	Debug.Trace("[CHIM] TakeASeat start")

		
	if (akTarget.IsFurnitureInUse()) 
		Debug.Notification("[CHIM] Sitting at "+akTarget.GetDisplayName()+", but seems in use")
	endif;
	
	Package SeatPackage = Game.GetFormFromFile(0x01C6E9, "AIAgent.esp") as Package ; Package AIAgentSeatPackage
	Faction SeatFaction=Game.GetFormFromFile(0x01C6EA, "AIAgent.esp") as Faction ; Faction AIAgentFactionSeat
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	
	npc.SetFactionRank(SeatFaction,1)
	npc.RemoveFromFaction(FollowFaction);
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, SeatPackage, 100)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	Debug.Notification("[CHIM] Sitting at "+akTarget.GetDisplayName())
	Debug.Trace("[CHIM] TakeASeat end")


endFunction

function SleepInBed(Actor npc, ObjectReference akTarget) global
	
	Debug.Trace("[CHIM] SleepInBed start")

	if (akTarget.IsFurnitureInUse()) 
		Debug.Notification("[CHIM] Sitting at "+akTarget.GetDisplayName()+", but seems in use")
	endif;
	
	Package SleepPackage = Game.GetFormFromFile(0x027e38, "AIAgent.esp") as Package ; Package AIAgentSleepPackage
	Faction SeatFaction=Game.GetFormFromFile(0x01C6EA, "AIAgent.esp") as Faction ; Faction AIAgentFactionSeat
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	
	npc.SetFactionRank(SeatFaction,1)
	npc.RemoveFromFaction(FollowFaction);
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, SleepPackage, 100)
	npc.EvaluatePackage()
	
	
	Debug.Trace("[CHIM] SleepInBed end")


endFunction

function TakeASeatEnd(Actor npc) global
	Package SeatPackage = Game.GetFormFromFile(0x01C6E9, "AIAgent.esp") as Package ; Package MoveToTarget
	Faction SeatFaction=Game.GetFormFromFile(0x01C6EA, "AIAgent.esp") as Faction ; Faction MoveToTarget
	npc.RemoveFromFaction(SeatFaction)
	ActorUtil.RemovePackageOverride(npc, SeatPackage)

	npc.EvaluatePackage()
	PO3_SKSEFunctions.SetLinkedRef(npc,None)
	AIAgentFunctions.commandEnded("TakeASeat")
	;Debug.Notification("[CHIM] End of sit: "+npc.GetDisplayName())
	

endFunction


function SneakToTarget(Actor npc, ObjectReference akTarget) global
	

endFunction

function SneakToTargetEnd(Actor npc) global

	

endFunction


function StartWait(Actor npc) global


	Debug.Trace("[CHIM] "+npc.GetDisplayName()+" waits" )

	Package WaitPackage = Game.GetFormFromFile(0x02021F, "AIAgent.esp") as Package ; Package WaitPackage
	Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 

	npc.RemoveFromFaction(FollowFaction);

	npc.SetFactionRank(WaitFaction,1)
	
	ActorUtil.AddPackageOverride(npc, WaitPackage, 100, 0)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	;Debug.Notification("[CHIM] "+npc.GetDisplayName()+" waits" )
	
	

endFunction

function StartWaitSoft(Actor npc) global


	Debug.Trace("[CHIM] "+npc.GetDisplayName()+" waits" )

	Package WaitPackage = Game.GetFormFromFile(0x0268b1, "AIAgent.esp") as Package ; Package WaitPackage
	Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 

	npc.RemoveFromFaction(FollowFaction);

	npc.SetFactionRank(WaitFaction,1)
	
	ActorUtil.AddPackageOverride(npc, WaitPackage, 50)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	;Debug.Notification("[CHIM] "+npc.GetDisplayName()+" waits" )
	
	

endFunction

function EndWait(Actor npc) global

	Debug.Trace("[CHIM] End of wait: "+npc.GetDisplayName())

	Package WaitPackage = Game.GetFormFromFile(0x02021F, "AIAgent.esp") as Package ; Package WaitPackage
	Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	npc.RemoveFromFaction(WaitFaction)
	ActorUtil.RemovePackageOverride(npc, WaitPackage)

	npc.EvaluatePackage()
	
	AIAgentFunctions.commandEnded("WaitHere")
	;Debug.Notification("[CHIM] End of wait: "+npc.GetDisplayName())

endFunction

function EndWaitSoft(Actor npc) global

	Debug.Trace("[CHIM] End of wait: "+npc.GetDisplayName())

	Package WaitPackage = Game.GetFormFromFile(0x0268b1, "AIAgent.esp") as Package ; Package WaitPackage
	Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	npc.RemoveFromFaction(WaitFaction)
	ActorUtil.RemovePackageOverride(npc, WaitPackage)

	npc.EvaluatePackage()
	
	;Debug.Notification("[CHIM] End of wait: "+npc.GetDisplayName())

endFunction

function Follow(Actor npc, ObjectReference akTarget) global
	
	
	ResetPackages(npc);
	Package FollowPackage = Game.GetFormFromFile(0x01BC25, "AIAgent.esp") as Package 
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	Keyword MoveTargetKw = Game.GetFormFromFile(0x021245,"AIAgent.esp") as Keyword	; // Psijic Monk Outfit

	
	
	npc.SetFactionRank(FollowFaction,1)
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget,MoveTargetKw)
	ActorUtil.AddPackageOverride(npc, FollowPackage, 100, 0)
	npc.EvaluatePackage()
	Debug.Notification("[CHIM] "+npc.GetDisplayName()+" following  "+akTarget.GetDisplayName())

	
	
endFunction

function FollowSoft(Actor npc, ObjectReference akTarget) global
	
	; used by get into conversation to make NPC talk near plater
	;ResetPackages(npc);
	Package FollowPackageSoft = Game.GetFormFromFile(0x0268b0, "AIAgent.esp") as Package 
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	Keyword MoveTargetKw = Game.GetFormFromFile(0x021245,"AIAgent.esp") as Keyword	; // Psijic Monk Outfit

	;
	Package SeatPackage = Game.GetFormFromFile(0x01C6E9, "AIAgent.esp") as Package ; Package AIAgentSeatPackage
	Faction SeatFaction=Game.GetFormFromFile(0x01C6EA, "AIAgent.esp") as Faction ; 
	
	npc.RemoveFromFaction(SeatFaction)
	ActorUtil.RemovePackageOverride(npc, SeatPackage)
	
	npc.SetFactionRank(FollowFaction,1)
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget,MoveTargetKw) ;AIAgentMoveLocation keyword
	ActorUtil.AddPackageOverride(npc, FollowPackageSoft, 50, 0)
	npc.EvaluatePackage()
	;Debug.Notification("[CHIM] "+npc.GetDisplayName()+" sandboxing near "+akTarget.GetDisplayName())
	Debug.Trace("[CHIM] "+npc.GetDisplayName()+" sandboxing near "+akTarget.GetDisplayName())

	
	
endFunction

function StopCurrent(Actor npc) global
	npc.EnableAI(false) 
	npc.stopCombat()
	
	Faction AttackFaction=Game.GetFormFromFile(0x01B6C1 , "AIAgent.esp") as Faction ; Faction AttackFaction
	Faction TravelFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	Faction WaitFaction=  Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	Faction SeatFaction=  Game.GetFormFromFile(0x01C6EA, "AIAgent.esp") as Faction ; Faction AIAgentFactionSeat

	Faction MoveToFaction=Game.GetFormFromFile(0x01A69B, "AIAgent.esp") as Faction ; Faction MoveToTarget
	Faction SandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction
	
	
	;npc.RemoveFromFaction(moveToFaction)
	npc.RemoveFromFaction(AttackFaction)
	npc.RemoveFromFaction(FollowFaction)
	npc.RemoveFromFaction(TravelFaction)
	npc.RemoveFromFaction(WaitFaction)
	npc.RemoveFromFaction(SeatFaction)
	npc.RemoveFromFaction(MoveToFaction)
	npc.RemoveFromFaction(SandboxFaction)
	AIAgentFunctions.setLocked(0,npc.GetDisplayName())

	ResetPackages(npc);
	ActorUtil.ClearPackageOverride(npc)
	
	PO3_SKSEFunctions.SetLinkedRef(npc,None)
	
	npc.EvaluatePackage()
	
	
	npc.EnableAI(true) 
	SheatheWeapon(npc)
	Debug.Notification("[CHIM] Stopped all actions")

endFunction

function SheatheWeapon(Actor npc) global
	
    Weapon weaponRight = npc.GetEquippedWeapon(false)
	if (weaponRight)
		npc.unequipItem(weaponRight)
	endif
	If npc.IsWeaponDrawn() ;If Player has a weapon drawn,
		npc.SheatheWeapon() ;Sheathe the drawn weapon.
	EndIf


endFunction



function TravelToTargetPlayer(Actor npc, ObjectReference akTarget,String place) global
	Game.SetPlayerAiDriven(true)
	Game.DisablePlayerControls(1, 1, 0, 0, 1, 0, 1)
	ResetPackages(npc);
	
	Package TraveltoPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Faction TraveToFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	npc.SetFactionRank(TraveToFaction,1)
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, TraveltoPackage, 99, 0)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	Debug.Trace("[CHIM] "+npc.GetDisplayName()+ " starts travel to "+place);
endFunction

;Travel to location

function TravelToLocation(Actor npc, ObjectReference akTarget,String place) global
	
	Package TraveltoPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Faction TraveToFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	Faction SandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction
		
	if (npc.Is3dLoaded())
		; Properly reset
		PO3_SKSEFunctions.SetLinkedRef(npc,None)
		ResetPackages(npc);
		Utility.wait(1); Give some time to package stack to apply
		
	endif;		

	npc.RemoveFromFaction(SandboxFaction)
	npc.RemoveFromFaction(FollowFaction)
	npc.RemoveFromFaction(WaitFaction)
	
	npc.SetFactionRank(TraveToFaction,1)

	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, TraveltoPackage, 100)
	npc.EvaluatePackage()
	
	StorageUtil.SetFormValue(npc, "LastTravelToLocation",akTarget);
	StorageUtil.SetStringValue(npc, "LastTravelToLocationName",place);
	Debug.Trace("[CHIM] TravelToLocation "+npc.GetDisplayName()+ " starts travel to "+place+" reference "+akTarget.GetFormId());
	;Debug.Notification("Mission MoveToTarget start")
	Debug.Notification("[CHIM] "+npc.GetDisplayName()+ " starts travel to "+place)
endFunction

;Travel to reference
function TravelToTarget(Actor npc, ObjectReference akTarget,String place) global
	Debug.Trace("TravelToTarget called: "+npc.GetDisplayName())
	ResetPackages(npc);

	Utility.wait(5);
	Package TraveltoPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Faction TraveToFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	Faction SandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	
	npc.RemoveFromFaction(SandboxFaction)
	npc.RemoveFromFaction(FollowFaction)
	npc.RemoveFromFaction(WaitFaction)
	
	npc.SetFactionRank(TraveToFaction,1)
	
	StorageUtil.SetFormValue(npc, "LastTravelToLocation",akTarget);
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, TraveltoPackage, 100, 0)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	if (place=="")
		place="a Unknown Place";
		AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" has left the place","infoaction",npc.GetDisplayName())
	endif;
	Debug.Notification("[CHIM] "+npc.GetDisplayName()+ " starts travel to "+place);
	Debug.Trace("[CHHIM] TravelToTarget called: "+npc.GetDisplayName()+" "+place+ ", actor"+akTarget.GetDisplayName())
endFunction

function TravelToTargetEnd(Actor npc) global
	Package TravelPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Faction TravelFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	Keyword MoveTargetKw = Game.GetFormFromFile(0x021245,"AIAgent.esp") as Keyword	; // Psijic Monk Outfit

	npc.RemoveFromFaction(TravelFaction)
	ActorUtil.RemovePackageOverride(npc, TravelPackage)

	PO3_SKSEFunctions.SetLinkedRef(npc,None,MoveTargetKw)
	npc.EvaluatePackage()
	
	ObjectReference destination=StorageUtil.GetFormValue(npc, "LastTravelToLocation") as ObjectReference;
	if (destination)
		Form dest=destination.GetBaseObject()
		if (dest.GetType()==43) 
			Actor destinationActor=StorageUtil.GetFormValue(npc, "LastTravelToLocation") as Actor
			if (destinationActor.IsDead()); Inspecting a dead body
				Debug.Notification("[CHIM] "+npc.GetDisplayName()+ " inspects "+destinationActor.getDisplayName())
				LookAt(npc,destinationActor)
				Debug.SendAnimationEvent(npc,"IdleKneeling")
				Utility.wait(3)
				Debug.SendAnimationEvent(npc,"IdleForceDefaultState")
			endif
			Debug.Trace("[CHIM] TravelToTargetEnd: "+npc.GetDisplayName()+". Travel destination was "+destinationActor.GetName()+" "+destinationActor.GetFormId()+" "+destinationActor.GetType())
			;stayAtPlace(npc,0,"");
		elseif (dest.GetType()==34) 
					; TravelToLocation case?
			String destinationName=StorageUtil.GetStringValue(npc, "LastTravelToLocationName") as String;
			if (destinationName)
				Debug.Trace("[CHIM] TravelToTargetEnd: "+npc.GetDisplayName()+". Travel destination was "+destinationName+" "+destination.GetFormId()+"  "+destination.GetType())
				if (!npc.Is3DLoaded())
					;Only log as background event id npc is not 3dloaded
					;AIAgentFunctions.logMessageForActor(npc.GetDisplayName() +" reaches destination "+destinationName,"backgroundaction",npc.GetDisplayName())
					Debug.Trace("[CHIM] TravelToTargetEnd: "+npc.GetDisplayName()+". Travel destination was "+destinationName+" "+destination.GetFormId()+"  "+destination.GetType()+ ", npc should wait here")
					Package doNothing = Game.GetForm(0x654e2) as Package ; Package Travelto
					ActorUtil.AddPackageOverride(npc, doNothing,100)
				endif
				StorageUtil.SetFormValue(npc, "LastTravelToLocation",None);
				StorageUtil.SetStringValue(npc, "LastTravelToLocationName",None);
			endif

		endif
	else
		; TravelToLocation case?
		Debug.Trace("TravelToTargetEnd: "+npc.GetDisplayName())
	endif
		
	
	AIAgentFunctions.commandEndedForActor("TravelTo",npc.GetDisplayName())
	;Debug.Notification("[CHIM] End travelling for "+npc.GetDisplayName() )

endFunction

int Function MoveToPlayer(Actor npc,String taskid) global;Review this
	;used by server spawn
	Package FollowPlayerPackage = Game.GetFormFromFile(0x2226d,"AIAgent.esp") as Package		; FollowPlayerPackage
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	;Package SandboxPackage = Game.GetFormFromFile(0x20ce2,"AIAgent.esp") as Package		; Package sandboxPackage 
	;Faction SandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction

	;Actor finalActor=npc;
	npc.SetFactionRank(FollowFaction,1)
	ActorUtil.AddPackageOverride(npc, FollowPlayerPackage, 100,0)
	;finalActor.SetFactionRank(SandboxFaction,1)
	
	;ActorUtil.AddPackageOverride(finalActor, SandboxPackage, 65,0)
	AIAgentFunctions.logMessageForActor("moving@"+npc.GetDisplayName()+"@"+taskid,"status_msg",npc.GetDisplayName())
    
	Utility.wait(3);
	
	;Only fire this after spawn
	
	
	if (npc.GetParentCell()==Game.GetPlayer().GetParentCell())
		Debug.Trace("Actor is present");
		AIAgentAIMind.MoveToTarget(npc,Game.GetPlayer(),3); 
	else
		Debug.Trace("Actor is not present");
		AIAgentAIMind.MoveToTarget(npc,Game.GetPlayer(),3); 
	endif;
	
EndFunction

int Function stayAtPlace(Actor npc,int followPlayer,String taskid = "") global

	Debug.Trace("START stayAtPlace "+npc.GetDisplayName())
	ResetPackages(npc);
	
	
	Faction BardAudienceExcludedFaction = Game.GetForm(0x10fcb4) as Faction		; Package sandboxPackage 
	npc.SetFactionRank(BardAudienceExcludedFaction,1)
	
	if (followPlayer==0)
		Package SandboxPackage = Game.GetFormFromFile(0x20ce2,"AIAgent.esp") as Package		; Package sandboxPackage 
		Faction SandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction
		npc.SetFactionRank(SandboxFaction,1)
		ActorUtil.AddPackageOverride(npc, SandboxPackage, 99,0)
		npc.EvaluatePackage();
	elseif (followPlayer==1)
		
		Package FollowPlayerPackage = Game.GetFormFromFile(0x2226d,"AIAgent.esp") as Package		; FollowPlayerPackage
		Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
			
		npc.SetFactionRank(FollowFaction,1)
		ActorUtil.AddPackageOverride(npc, FollowPlayerPackage, 100,0)
		npc.EvaluatePackage();
	endif
	
	Debug.Trace("END stayAtPlace "+npc.GetDisplayName())
	;AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" talks to "+(Game.GetPlayer().GetDisplayName())+" about the topic he/she knows","instruction",npc.GetDisplayName())

EndFunction




function OpenInventory(Actor npc,string originalCommand) global
	Faction CurrentFollowerFaction=Game.GetForm(0x5c84e) as Faction; PlayerFollowerFaction
	Debug.Notification("[CHIM] OpenInventory "+npc.GetDisplayName() )
	
	if (originalCommand=="OpenInventory2")
		Debug.Trace("[CHIM] Call ShowGiftMenu "+npc.GetDisplayName() )
		npc.ShowGiftMenu(true,None,false,false);
	else 
		if (npc.IsPlayerTeammate())
			if (npc.GetFactionRank(CurrentFollowerFaction)>-1)
				Debug.Trace("[CHIM] Call OpenInventory "+npc.GetDisplayName() )
				npc.OpenInventory(true);
			else	
				Debug.Trace("[CHIM] Call ShowBarterMenu "+npc.GetDisplayName() )
				npc.ShowBarterMenu();
			endif
		else
			Debug.Trace("[CHIM] Call ShowBarterMenu "+npc.GetDisplayName() )
			;npc.ShowGiftMenu(true,None,false,false);
			npc.ShowBarterMenu();
		endif
	endif
endFunction


function AttackTarget(Actor npc, ObjectReference akTarget,bool lethal=true) global
		
	ResetPackages(npc);
	Package AttackPackage = Game.GetFormFromFile(0x01B6C2 , "AIAgent.esp") as Package 
	Faction AttackFaction=Game.GetFormFromFile(0x01B6C1 , "AIAgent.esp") as Faction 
	
	Faction SandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	
	npc.SetFactionRank(AttackFaction,1)
	npc.RemoveFromFaction(SandboxFaction)
	npc.RemoveFromFaction(FollowFaction)

	Actor targetAsActor = akTarget as Actor

	string combatString=" engages fair combat with "
	if (!lethal)
		combatString=" engages non-lethal fair combat with "
	endif
	
	;Faction WEPlayerEnemy=Game.GetForm(0x0001DD0F) as Faction ; WEPlayerEnemy
	;targetAsActor.SetFactionRank(WEPlayerEnemy,1)
	
	
	;npc.ModActorValue("aggression", 3)
	;npc.ModActorValue("morality", 0)
	;npc.SetPlayerTeammate(false,true);
	Debug.trace("[CHIM] AttackTarget "+npc.getDisplayName()+" vs "+ targetAsActor.getDisplayName())
	
	if (targetAsActor)
	
		if (npc.GetDistance(targetAsActor)<2048)
			
			;npc.SetActorValue("Confidence",4)
			;npc.SetRelationshipRank(targetAsActor, -3)
			;targetAsActor.SetRelationshipRank(npc, -3)
			;npc.startCombat(targetAsActor);
			
			npc.SetActorValue("Confidence",4); Review this. Maybe we shoud restore
			npc.SetRelationshipRank(targetAsActor, -3)
			targetAsActor.SetRelationshipRank(npc, -3)
			
			if (!lethal)
				; To-DO reover this values after combat
				Debug.trace("[CHIM] Non Lethal AttackTarget "+npc.getDisplayName()+" vs "+ targetAsActor.getDisplayName())
				if (!StorageUtil.HasIntValue(npc, "CHIM_Protected"))
					bool originallyProtected=AIAgentNpcUtil.getProperActorBase(npc).IsProtected();
					if (originallyProtected)
						StorageUtil.SetIntValue(npc, "CHIM_Protected",1);
					else
						StorageUtil.SetIntValue(npc, "CHIM_Protected",0);
					endif
				endif
				
				if (!StorageUtil.HasIntValue(targetAsActor, "CHIM_Protected"))
					bool originallyProtected=AIAgentNpcUtil.getProperActorBase(targetAsActor).IsProtected();
					if (originallyProtected)
						StorageUtil.SetIntValue(targetAsActor, "CHIM_Protected",1);
					else
						StorageUtil.SetIntValue(targetAsActor, "CHIM_Protected",0);
					endif
				endif
				
				
				if (!StorageUtil.HasIntValue(npc, "CHIM_BleedRecovery"))
					bool originalValue=npc.GetNoBleedoutRecovery()
					if (originalValue)
						StorageUtil.SetIntValue(npc, "CHIM_BleedRecovery",1);
					else
						StorageUtil.SetIntValue(npc, "CHIM_BleedRecovery",0);
					endif
				endif
				
				if (!StorageUtil.HasIntValue(targetAsActor, "CHIM_BleedRecovery"))
					bool originalValue=targetAsActor.GetNoBleedoutRecovery()
					if (originalValue)
						StorageUtil.SetIntValue(targetAsActor, "CHIM_BleedRecovery",1);
					else
						StorageUtil.SetIntValue(targetAsActor, "CHIM_BleedRecovery",0);
					endif
				endif
				Debug.Trace(npc.GetDisplayName()+" and "+targetAsActor.GetDisplayName()+" are now protected")
				; Set actors protected as non-lethal fight
				AIAgentNpcUtil.getProperActorBase(npc).SetProtected()
				AIAgentNpcUtil.getProperActorBase(targetAsActor).SetProtected()
				
				npc.SetNoBleedoutRecovery(true);
				targetAsActor.SetNoBleedoutRecovery(true)
				;npc.SendAssaultAlarm();
			endif
			npc.startCombat(targetAsActor);
			
			AIAgentFunctions.logMessageForActor("command@Attack@"+akTarget.GetDisplayName()+"@"+npc.GetDisplayName()+combatString+akTarget.GetDisplayName(),"funcret",npc.GetDisplayName())
			
		else 
			PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
			ActorUtil.AddPackageOverride(npc, AttackPackage, 100, 0)
			npc.EvaluatePackage()
			;npc.startCombat(targetAsActor);
			Debug.Notification("[CHIM] "+npc.GetDisplayName()+" attacks "+akTarget.GetDisplayName())
			AIAgentFunctions.logMessageForActor("command@Attack@"+akTarget.GetDisplayName()+"@"+npc.GetDisplayName()+combatString+akTarget.GetDisplayName(),"funcret",npc.GetDisplayName())
		endif;
	else
		Debug.Notification("[CHIM] Could not reach target "+akTarget.GetDisplayName());
		;AIAgentFunctions.logMessage("command@Attack@"+akTarget.GetDisplayName()+"@"+npc.GetDisplayName()+" cannot attack "+akTarget.GetDisplayName(),"funcret")
		
	EndIf
	

endFunction

function RecoverFromCombat(Actor npc) global;Triggers on defeated actor

	
	if (StorageUtil.HasIntValue(npc, "CHIM_BleedRecovery"))	; Only applied if combat was started by brawl
		Actor winner=npc.GetCombatTarget();
		
		if (winner)
			Debug.Trace(npc.GetDisplayName()+" no more enemy with "+winner.GetDisplayName());
			npc.SetRelationshipRank(winner,0)
			winner.SetRelationshipRank(npc,0)
			winner.StopCombat()
			npc.StopCombat()
		endif
		AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" has lost combat and is wounded bleedingout.","instruction",npc.GetDisplayName())
		Utility.wait(10);Wait, sometimes opponent still agressive

		npc.RestoreAV("Health",20)	
		int original=StorageUtil.GetIntValue(npc, "CHIM_BleedRecovery")
		
		if (original==1)
			npc.SetNoBleedoutRecovery(true);
			Debug.Trace(npc.GetDisplayName()+" restoring SetNoBleedoutRecovery to true");

		else
			npc.SetNoBleedoutRecovery(false);
			Debug.Trace(npc.GetDisplayName()+" restoring SetNoBleedoutRecovery to false");
		endif
	endif
	
	Utility.wait(15);Wait, sometimes opponent still agressive

	npc.RestoreAV("Health",20)	
	if (StorageUtil.HasIntValue(npc, "CHIM_Protected"))
		int original=StorageUtil.GetIntValue(npc, "CHIM_Protected")
		
		if (original==1)
			AIAgentNpcUtil.getProperActorBase(npc).SetProtected();
			Debug.Trace(npc.GetDisplayName()+" restoring as protected")
		else
			AIAgentNpcUtil.getProperActorBase(npc).SetProtected(false);
			Debug.Trace(npc.GetDisplayName()+" restoring as non protected")
		endif
	endif
	
endFunction

function AttackTargetEnd(Actor npc) global
	Package AttackPackage = Game.GetFormFromFile(0x01B6C2 , "AIAgent.esp") as Package 
	Faction AttackFaction=Game.GetFormFromFile(0x01B6C1 , "AIAgent.esp") as Faction 
	npc.RemoveFromFaction(AttackFaction)
	ActorUtil.RemovePackageOverride(npc, AttackPackage)

	npc.EvaluatePackage()
	PO3_SKSEFunctions.SetLinkedRef(npc,None)
	
	AIAgentFunctions.commandEndedForActor("Attack",npc.GetDisplayName())
	;Debug.Notification("[CHIM] end attack command:  "+npc.GetDisplayName() )

endFunction

function StartCombat(Actor npc,ObjectReference victim) global


	Actor victimasActor = victim as Actor
	Debug.Trace("[CHIM] starting combat:  "+npc.GetDisplayName()+ " vs "+victim.GetDisplayName(),1)
	
	npc.SetActorValue("Aggression",2)		
	npc.SetActorValue("Confidence",4)
	npc.SetRelationshipRank(victimasActor, -3)
	
	npc.startCombat(victimasActor);

	Debug.Notification("[CHIM] starting combat:  "+npc.GetDisplayName()+ " vs "+victim.GetDisplayName())

endFunction


function SendInternalEvent(String npcname,String command,String parm) global

	int handle = ModEvent.Create("CHIM_CommandReceivedInternal")
	if (handle)
		ModEvent.PushString(handle, npcname)
		ModEvent.PushString(handle, command)
		ModEvent.PushString(handle, parm)
		ModEvent.Send(handle)
		;Debug.Notification("[CHIM] External command sent "+command+"@"+parm)

	endIf
endFunction

function SendExternalEvent(String npcname,String command,String parm) global

	int handle = ModEvent.Create("CHIM_CommandReceived")
	if (handle)
		ModEvent.PushString(handle, npcname)
		ModEvent.PushString(handle, command)
		ModEvent.PushString(handle, parm)
		ModEvent.Send(handle)
		;Debug.Notification("[CHIM] External command sent "+command+"@"+parm)
	endIf
endFunction

function SendExternalEventNPC(String npcname,String actionName) global

	int handle = ModEvent.Create("CHIM_NPC")
	if (handle)
		ModEvent.PushString(handle, npcname)
		ModEvent.PushString(handle, actionName)
		ModEvent.Send(handle)
		;Debug.Trace("[CHIM] CHIM_NPC "+npcname+" "+actionName)
	endIf
endFunction


function SendExternalEventChat(String npcname,String text) global


	int handle = ModEvent.Create("CHIM_TextReceived")
	if (handle)
		ModEvent.PushString(handle, npcname)
		ModEvent.PushString(handle, text)
		ModEvent.Send(handle)
		;Debug.Trace("[CHIM] CHIM_TextReceived sent "+npcname+"@"+text)
	endIf

endFunction


function SayToPlayer(Actor npc) global
	Debug.Notification("[CHIM] Use new queue mode")
	;Topic fixedTopic=Game.GetFormFromFile(0x00638E, "AddDiagToReplace.esp") as Topic ; AASPGQuestDialogue2Topic1B1Topic
	;if (fixedTopic)
	;	npc.Say(fixedTopic,npc,false)
	;else
	;	Debug.Notification("[CHIM] Topic Not found")
	;endIf

endFunction


function WaitHere(Actor npc) global
	; deprecated, should use package
	Debug.Notification("[CHIM] "+npc.GetDisplayName())+" will wait here";
	;Topic fixedTopic=Game.GetFormFromFile(0x00638E, "AddDiagToReplace.esp") as Topic ; AASPGQuestDialogue2Topic1B1Topic
	;if (fixedTopic)
	;	npc.Say(fixedTopic,npc,false)
	;else
	;	Debug.Notification("[CHIM] Topic Not found")
	;endIf

endFunction


function LookAt(Actor npc,Actor target) global
	
	if (npc!=Game.GetPlayer())
		npc.SetLookAt(target)
	else 
		Debug.Trace("[CHIM] LookAt on Player, avoiding");
	endif
	
endFunction



function PlayIdle(Actor npc,int animation) global

	; extra checks
	if (npc.IsBleedingOut())
		return
	elseif (npc.IsInCombat())
		return
	elseif (npc.IsSneaking())
		return
	elseif (npc.GetCurrentScene())
		return
	endif;
	
	npc.PlayIdle(Game.GetForm(animation) as Idle)
	
endFunction

Function GetIntoConversation(Actor npc,ObjectReference reference) global

	int isActive=StorageUtil.GetIntValue(None, "AIAgentNpcWalkNear",1);
	if (isActive==0)
		return;
	endif
	
	if (Game.GetPlayer().GetSitState()==0 || (Game.GetPlayer().IsOnMount())) ; Dont use feature if player is not sitting, or is on a mount
		return;
	else
		;Debug.Trace("Player is sitting");
	endif
	
	ObjectReference finalReference;
	
	if (reference.GetDistance(Game.GetPlayer())<256)
		; Use reference as is close to player 
		finalReference=reference
	else
		; Use player as reference , npc should aproach player while talking
		finalReference=Game.GetPlayer()
	endif;
	
	if (!npc.IsinCombat() && !npc.IsInKillMove() && !npc.IsRunning() && !npc.IsUnconscious() && !npc.IsHostileToActor(npc) && !npc.GetCurrentScene())
		if (npc.GetDistance(finalReference)>1024 ) 
			Package isRunningPackage=StorageUtil.GetFormValue(npc, "PackageSoft",None) as Package;
			if (!isRunningPackage)
				; Seems listener NPC is sandboxing, lets gently move it to speaker*/player 
				
				Package FollowPackageSoft = Game.GetFormFromFile(0x0268b0, "AIAgent.esp") as Package 
				StorageUtil.SetFormValue(npc, "PackageSoft",FollowPackageSoft) as Package;
				FollowSoft(npc,finalReference);
			else 
				; NPC should be aproaching
			EndIf
		elseif (npc.GetDistance(finalReference)<300 ) 
			Package isRunningPackage=StorageUtil.GetFormValue(npc, "PackageSoft",None) as Package;
			if (isRunningPackage)
				; Now it's close enough, release it and make it wait 300 seconds.
				StorageUtil.SetFormValue(npc, "PackageSoft",None) ;
				Keyword MoveTargetKw = Game.GetFormFromFile(0x021245,"AIAgent.esp") as Keyword	; // Psijic Monk Outfit

				PO3_SKSEFunctions.SetLinkedRef(npc,None,MoveTargetKw)
				ActorUtil.RemovePackageOverride(npc, isRunningPackage)
				; Remove FollowFaction so package FollowPackageSoft won't apply anymore
				Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
				npc.RemoveFromFaction(FollowFaction)

				StartWaitSoft(npc)
				
			EndIf
		endif
	endif

EndFunction

Function ReleaseFromConversation(Actor npc) global

	int isActive=StorageUtil.GetIntValue(None, "AIAgentNpcWalkNear",1);
	if (isActive==0)
		return;
	endif
	
	Package isRunningPackage=StorageUtil.GetFormValue(npc, "PackageSoft",None) as Package;
	Debug.Trace("[CHIM] "+npc.GetDisplayName()+" is running package "+isRunningPackage)
	if (isRunningPackage)
		Package FollowPackageSoft = Game.GetFormFromFile(0x0268b0, "AIAgent.esp") as Package 
		ActorUtil.RemovePackageOverride(npc, isRunningPackage)
		Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
		npc.RemoveFromFaction(FollowFaction);
		Debug.Trace("[CHIM] "+npc.GetDisplayName()+" stops PackageSoft")
	EndIf		
	StorageUtil.SetFormValue(npc, "PackageSoft",None);
	
	
	npc.EvaluatePackage()
	
	;npc.EnableAI(false);
	;npc.EnableAI(true);
	
	;Debug.Notification("[CHIM] "+npc.GetDisplayName()+" leaves conversation")
	Debug.Trace("[CHIM] "+npc.GetDisplayName()+" leaves conversation")
	
EndFunction

function FakeDialogueWith(Actor npc,Actor listener, int animation,int movehead) global

	; Should be called after NPC starts speech to listener (every sentence)
	
	int handle = ModEvent.Create("CHIM_SpeechStarted")
	if (handle)
		Debug.Trace("[CHIM] Sending event CHIM_SpeechStarted");
		ModEvent.PushForm(handle, npc)
		ModEvent.Send(handle)
	endIf
	
	if ((animation > 0) && !npc.IsInCombat())
		npc.PlayIdle(Game.GetForm(animation) as Idle)
	else
		;Debug.SendAnimationEvent(npc, "IdleDialogueExpressiveStart")	
	EndIf
	
	;placeCam(npc,listener)
	
	if (movehead == 1 || true)
	
		if (npc!=Game.GetPlayer())
			npc.SetLookAt(listener)
		else 
			Debug.Trace("[CHIM] LookAt on Player, avoiding");
		endif
		
		if (listener!=Game.GetPlayer())
			listener.SetLookAt(npc)
		else 
			Debug.Trace("[CHIM] LookAt on Player, avoiding");
		endif

		GetIntoConversation(listener,npc as ObjectReference ) ; if listener is too far away, move listener to speaker if speaker close to player, if not close,  move near player
		GetIntoConversation(npc,listener); if speaker is too far away, Move speaker to listener if listener near to player, if not, move to player 

	endif
	
	PlaceCam(npc);
	
	
	;PlaceCam(npc)
	
	;Game.DisablePlayerControls(abMovement = true, abFighting = true, abCamSwitch = true, abLooking = true, abSneaking = true, abMenu = true, abActivate = true, abJournalTabs = false, aiDisablePOVType = 0)
	
	;Utility.wait(1);
	;Game.EnablePlayerControls()
	
endFunction

function FakeDialogue(Actor npc,int animation,int movehead) global
	
	int handle = ModEvent.Create("CHIM_SpeechStarted")
	if (handle)
		Debug.Trace("[CHIM] Sending event CHIM_SpeechStarted");
		ModEvent.PushForm(handle, npc)
		ModEvent.Send(handle)
	endIf
	
	; Should be called after NPC starts speech to player (every sentence)
	if (npc!=Game.GetPlayer())
		npc.SetLookAt(Game.GetPlayer())
	else 
		Debug.Trace("[CHIM] LookAt on Player, avoiding");
	endif
	
	GetIntoConversation(npc,Game.GetPlayer())
	;placeCam(npc,Game.GetPlayer())
	
	if ((animation > 0) && !npc.IsInCombat())
		;npc.PlayIdle(Game.GetForm(0x000FFA0C) as Idle)
		npc.PlayIdle(Game.GetForm(animation) as Idle)
		
	else
		;Debug.SendAnimationEvent(npc, "IdleDialogueExpressiveStart")
	EndIf

	PlaceCam(npc);
	
endFunction



function PrepareForDialog(Actor npc) global
	; Before LLM response. User just talked. Called when NPC was talking or in dialog, so we must reset mouth position
	if (!npc.IsOnMount())
		npc.QueueNiNodeUpdate()
	else 
		npc.RegenerateHead()
	endif
	;AIAgentFaceReset.resetFace(npc);
	


endFunction

function resetExpression(Actor target) global
	
	;AASPGHerikaFaceReset.resetExpression(target);

endFunction


function EndDialogue(Actor npc) global
	; Should be called after NPC stops speech
	;;npc.ClearLookAt()

	int handle = ModEvent.Create("CHIM_SpeechStopped")
	if (handle)
		Debug.Trace("[CHIM] Sending event CHIM_SpeechStopped");
		ModEvent.PushForm(handle, npc)
		ModEvent.Send(handle)
		;Debug.Trace("[CHIM] CHIM_TextReceived sent "+npcname+"@"+text)
	endIf
	
endFunction

function EndDialogueClear(Actor npc) global
	; Should be called when cleaning NPC state (about 4 seconds adter las speech)
	
	Debug.Trace("[CHIM] EndDialogueClear "+npc.GetDisplayName());
	if (npc!=Game.GetPlayer())
		npc.ClearLookAt()
	else 
		Debug.Trace("[CHIM] ClearLookAt on Player, avoiding");
	endif
		
	;resetCam();
	
	;Topic NullTopic = Game.GetFormFromFile(0x01dc74, "AIAgent.esp") as Topic 
	;npc.Say(NullTopic)

endFunction

function EndDialogueClearScene(Actor npc) global

	; Should be called when cleaning NPC state (about 90 seconds after last speech) and NPC was on scene
	if (npc!=Game.GetPlayer())
		npc.ClearLookAt()
	else 
		Debug.Trace("[CHIM] ClearLookAt on Player, avoiding");
	endif

	Utility.wait(5);	
	npc.ClearExpressionOverride();
	
	; Try to restart scene, can break quests
	if (npc.GetCurrentScene())
		
			Scene currentScene=npc.GetCurrentScene();
			currentScene.Stop();
			Utility.wait(1);	
			currentScene.Start();
		
	else 
		if (npc.GetCurrentPackage())
			if (npc.GetCurrentPackage().GetOwningQuest())
				Quest questScene=npc.GetCurrentPackage().GetOwningQuest();
				questScene.Stop();
				Utility.wait(1);	
				questScene.Start();
			else 
				;
			endif
		endif
	
	endif;
	;Package doNothing=Game.GetFormFromFile(0x027374, "AIAgent.esp") as Package
	;Debug.Trace("[CHIM] GetFormFromFile is "+doNothing);
	;ActorUtil.AddPackageOverride(npc, doNothing,99,0)

	;Topic nulltopic=Game.GetFormFromFile(0x01DC74, "AIAgent.esp") as Topic
	;npc.Say(nulltopic)
	
	;npc.GetCurrentScene().Start();
	Package runningPackage=npc.GetCurrentPackage() as Package;
	Debug.Trace("[CHIM] EndDialogueClearScene on "+npc.GetDisplayName()+", voice is:"+npc.GetVoiceType());
	Debug.Trace("[CHIM] GetCurrentPackage is "+runningPackage);
	
	;AIADialogueNullResetTopic
	;Topic NullTopic = Game.GetFormFromFile(0x01dc74, "AIAgent.esp") as Topic 
	;npc.Say(NullTopic)

endFunction

function EquipSpellOnPlayer(int spellFormId) global

	Spell  spellToEquip=Game.GetForm(spellFormId) as Spell 
	if (Game.GetPlayer().HasSpell(spellToEquip))
		Game.GetPlayer().EquipSpell(spellToEquip, 0) ; Gives BoundBow to player if they don't have it
		Game.GetPlayer().DrawWeapon()
		Debug.Notification("[CHIM] Equipping spell "+spellToEquip.GetName())
	else
		Debug.Notification("[CHIM] You must learn "+spellToEquip.GetName())
	endif
endFunction

function FillLogJournal(int FormId) global
	Quest feedIdle=Game.GetForm(FormId) as Quest
	if (feedIdle.GetID())
	
		ConsoleUtil.PrintMessage("-")
		ConsoleUtil.ExecuteCommand("ShowFullQuestLog "+feedIdle.GetID()) 
		String log=ConsoleUtil.ReadMessage() 
		if (log !="-")
			AIAgentFunctions.logMessage(feedIdle.GetID()+"@"+log,"_questdata")
		EndIf
	endif
endFunction


;; WIP RPQG functions


ObjectReference Function FindFarthestReferenceAroundPlayer(int type ,float radius) global 
    ; Get the player reference
    Actor PlayerRef = Game.GetPlayer()

    ; Get the cell the player is currently in
    Cell playerCell = PlayerRef.GetParentCell()

    ; Variables to track the farthest reference and its distance
    ObjectReference farthestRef = None
    float maxDistance = 0.0

    ; Iterate through all references (0 is for actors, but you can adjust for other types)
    int i = 0
    int numActors = playerCell.GetNumRefs(0) ; 0 is for actors, adjust for other types if needed

    while i < numActors
        ObjectReference ref = playerCell.GetNthRef(i, 0) ; 0 is for actors, can use 1 for other object types
		
		if (ref && ref.Is3dLoaded())
			Debug.trace("Found "+ref.getDisplayName()+ " / type "+ref.getType()+ " / "+ref.getName()+ " / "+ref.GetBaseObject().getType());
			if (ref.GetBaseObject().getType()== 27 || ref.GetBaseObject().getType()== 32 || ref.GetBaseObject().getType()== 48 || ref.GetBaseObject().getType()== 46 || ref.GetBaseObject().getType()==23 || ref.GetBaseObject().getType()==41 || ref.GetBaseObject().getType()==26|| ref.GetBaseObject().getType()==103|| ref.GetBaseObject().getType()==38)
			; Ensure the reference exists and is within the specified radius
				if (ref.GetDistance(PlayerRef) <= radius && ref.getDisplayName()!=""  && !Game.GetPlayer().HasLOS(ref) && ref.getType()==type)
					Debug.trace("Found "+ref.getDisplayName()+ " / type "+ref.getType()+ " / "+ref.getName()+ " / "+ref.GetBaseObject().getType());
					float currentDistance = ref.GetDistance(PlayerRef)

					; If the current reference is farther than the previous farthest, update the farthestRef
					if currentDistance > maxDistance
						farthestRef = ref
						maxDistance = currentDistance
					endif
				endif
			Endif
		endif

        i += 1
    endwhile

    ; Print or return information about the farthest reference
    if farthestRef
        Debug.Trace("Farthest Reference: " + farthestRef.GetDisplayName() + " at distance: " + maxDistance)
    else
        Debug.Trace("No references found within the radius.")
    endif

    ; You could also return the farthest reference to use elsewhere
    return farthestRef
EndFunction


int Function SpawnAgent(string npcName,Int FormIdNPC,Int FormIdClothing, Int FormIdWeapon,Int place,String taskid,Int FormIdNPCSource) global

	ObjectReference ref;
	bool move=true;
	if (place==0)
		if (Game.GetPlayer().IsInInterior())
			ref=AIAgentFunctions.getNearestDoor();
			if (!ref)
				ref=AIAgentFunctions.findLocationsToSafeSpawn(4096,false);
				Debug.Trace("[CHIM] Interior. spawning on safe spawn")
			else
				Debug.Trace("[CHIM] Interior. spawning on nearest door")			
				move=false;
			endif
		else
			ref=AIAgentFunctions.findLocationsToSafeSpawn(6000,false);
			Debug.Trace("[CHIM] Exterior. spawning on safe spawn")
		endif
	else
		ref=Game.GetForm(place) as ObjectReference
		Debug.Trace("[CHIM] Spawning on designed location "+ref.GetName())
	endif
	
	
	if (ref)
		Debug.Trace("[CHIM] spawning "+npcName+" / FormIdNPC "+FormIdNPC+ " / FormIdClothing:"+FormIdClothing+" / FormIdWeapon: "+FormIdWeapon+" / FormIdNPCSource: "+FormIdNPCSource);		
		ActorBase finalNpcToSpawn ;
		
		finalNpcToSpawn = Game.GetFormFromFile(FormIdNPC, "AIAgent.esp") as ActorBase ; We should choose a correct template here
		if (!finalNpcToSpawn)
			finalNpcToSpawn  = Game.GetForm(FormIdNPC) as ActorBase 
		endif;
		;finalNpcToSpawn = Game.GetForm(FormIdNPC) as ActorBase
	
		Outfit clothing 
		clothing = Game.GetForm(FormIdClothing) as Outfit  
		
		Weapon mainWeapon=Game.GetForm(FormIdWeapon)	as Weapon
	
		Actor finalActor;
		if (place==0)
			;finalActor=Game.GetPlayer().PlaceAtMe(finalNpcToSpawn,1,true,true) as Actor
			finalActor=ref.PlaceAtMe(finalNpcToSpawn,1,true,true) as Actor
		else
			finalActor=ref.PlaceAtMe(finalNpcToSpawn,1,true,true) as Actor
		endif
		
		
		finalActor.RemoveAllItems();
		finalActor.SetActorValue("Aggression",0)
		finalActor.RemoveFromAllFactions();
		;finalActor.MakePlayerFriend(); Check this
		finalActor.SetRelationshipRank(Game.GetPlayer(), 0) ; Check this
		
		
		finalActor.SetOutfit(clothing,false)
		finalActor.SetDisplayName(npcName,1)
		
		
		
		
		finalActor.EvaluatePackage()
		finalActor.AddItem(mainWeapon,1,true)
		finalActor.EquipItem(mainWeapon,false,true)
		;finalActor.SetScale(0.01)
		finalActor.Enable(true)
		
		ActorBase source = Game.GetForm(FormIdNPCSource) as ActorBase; Will use this actor base as source to copy hair.
		Actor finalSourceActor=Game.GetPlayer().PlaceAtMe(source,1,true,true) as Actor; Spawn source actor instance
		Debug.Trace("[CHIN] Source actorbase is "+source.GetFormID())


		;CopyApearanceFromTo(finalSourceActor,finalActor);
		CopyApearanceFromToComplex(finalSourceActor,finalActor); Copy appearance from source to dest

		
		
		if (place==0)
			;finalActor.MoveTo(ref)
			;finalActor.SetAngle(0,-180,0)
		else
			;finalActor.DisableNoWait();
			;finalActor.MoveTo(ref)
			;finalActor.EnableNoWait();
			;MoveToTarget(finalActor,ref)
		endif
		
		
		;finalActor.SetScale(1)
		
		finalSourceActor.Disable(); Remove source actor as is not needed anymore.
		
		AIAgentFunctions.setDrivenByAIA(finalActor,false)

		; Info purposes
		ActorBase instancedActBase=getProperActorBase(finalActor);
		int hp = getProperActorBase(finalActor).GetNumHeadParts()
		Debug.Trace("HeadParts Num : "+hp)
		int i = 0
		WHILE i < hp
			Debug.Trace("Player HeadPart("+i+") : "+instancedActBase.GetNthHeadPart(i).GetName()+" "+instancedActBase.GetNthHeadPart (i).GetType())
			int j=0;
			int ehp=instancedActBase.GetNthHeadPart(i).GetNumExtraParts();
			WHILE j < ehp
				Debug.Trace("Player ExtraHeadPart("+j+") : "+instancedActBase.GetNthHeadPart(i).GetNthExtraPart(j).GetName()+" "+instancedActBase.GetNthHeadPart(i).GetNthExtraPart(j).GetType())
				j += 1
			EndWHILE
			i += 1
		EndWHILE
		
		
		AIAgentFunctions.logMessageForActor("spawned@"+finalActor.GetDisplayName()+"@"+finalActor.GetFormId(),"status_msg",finalActor.GetDisplayName())

		string locationStr="";
		if (finalActor.GetCurrentLocation())
			locationStr = finalActor.GetCurrentLocation().GetName()
		endif
		Debug.Trace("[CHIM] Spawned "+finalActor.GetDisplayName()+" at "+locationStr)
		return 0
	EndIf

	return -1
EndFunction

int Function SpawnBook(string itemname,int itembase,int locationMarker ,String taskid,String content) global

	Debug.Trace("spawning "+itemname+" / itembase "+itembase+ " / location Marker:"+locationMarker);
	String locationName;
	ObjectReference ref
	if (locationMarker==0)
		ref=AIAgentFunctions.findLocationsToSafeSpawn(4096)
		locationName=ref.GetDisplayName();
	else 
		ref=Game.GetForm(locationMarker)  as ObjectReference;
		locationName=ref.GetDisplayName();
	endif

	Book itemToSpawnBase=Game.GetFormFromFile(0x022d30, "AIAgent.esp") as Book ; Package Travelto
	
	VisualEffect veff=Game.GetForm(0x0008cc8a)  as VisualEffect	
	Faction AIAssisted = Game.GetFormFromFile(0x021d0b,"AIAgent.esp") as Faction	; 
	
	Sound hintSound =Game.GetFormFromFile(0x0237F4,"AIAgent.esp")  as Sound	
	
	if (ref)
		String referencename=ref.GetDisplayName();
		if (referencename=="")
			referencename=ref.GetName();
		endif
		
		;ObjectReference finalItem=Game.GetPlayer().PlaceAtMe(itemToSpawn,1,true,true) 
		;finalItem.MoveToNode(Game.GetPlayer(),"h")
		ObjectReference finalItem=ref.PlaceAtMe(itemToSpawnBase,1,true,true) 
		
		finalItem.SetDisplayName(itemname,true)
		finalItem.SetFactionOwner(AIAssisted)
		Game.getPlayer().AddToFaction(AIAssisted); So item is not marked as stolen
		
		if (finalItem.Is3DLoaded())
			float deltaX=Utility.RandomFloat(-1, 1)
			float deltaY=Utility.RandomFloat(-1, 1)
			float deltaZ=Utility.RandomFloat(1,1)*0
			finalItem.MoveTo(ref, 0,0,deltaZ)
			finalItem.SetAngle(0,-180,0)
		Endif
		
		finalItem.SetScale(2)
		finalItem.Enable()
		Utility.wait(5)
		AIAgentFunctions.logMessage("spawned_book@"+itemname+"@success@"+locationName,"status_msg")
		Debug.Trace("spawned_item "+itemname+" / itembase "+itembase+ " / location Marker:"+locationMarker+ "/ FormID"+finalItem.GetFormId());
		
		if (finalItem.Is3DLoaded())
			veff.Play(finalItem);
			hintSound.Play(finalItem)
		endif
		
		Debug.Notification("Something is hidding near "+referencename);	
		
		;Debug.Notification("Something is hidding nearby");	
		return 0
	else
		AIAgentFunctions.logMessage("spawned_book@"+itemname+"@error","status_msg")
	EndIf

	return -1
EndFunction


int Function SpawnItem(string itemname,int itembase,int locationMarker ,String taskid) global

	Debug.Trace("[CHIM] spawning "+itemname+" / itembase "+itembase+ " / location Marker:"+locationMarker);
	
	ObjectReference ref
	if (locationMarker==0)
		ref=AIAgentFunctions.findLocationsToSafeSpawn(6000)
		if (!ref)
			Debug.Trace("[CHIM] UNRESTRICTED spawned_item "+itemname);
			ref=AIAgentFunctions.findLocationsToSafeSpawn(6000,false)
			
		endif
	else 
		ref=Game.GetFormEx(locationMarker)  as ObjectReference;
	endif

	if (ref)
		String referencename=ref.GetDisplayName();
		if (referencename=="")
			referencename=ref.GetName();
		endif
		
		MiscObject itemToSpawnBase=Game.GetFormFromFile(itembase,"AIAgent.esp")	as MiscObject; Necklace
		itemToSpawnBase.SetGoldValue(10000)
		EffectShader shader=Game.GetForm(0x00092de7)  as EffectShader	
		Enchantment ench=Game.GetForm(0x0010fb84)  as Enchantment	
		VisualEffect veff=Game.GetForm(0x0008cc8a)  as VisualEffect	
		Spell spellitem=Game.GetForm(0x043323)  as Spell	
		
		Faction AIAssisted = Game.GetFormFromFile(0x021d0b,"AIAgent.esp") as Faction	; 
		Sound hintSound =Game.GetFormFromFile(0x0237F4,"AIAgent.esp")  as Sound	
		
		ObjectReference finalItem;
		
		if (ref.GetBaseObject().getType()==43)	; if locationMarker is a NPC, item will go into its inventory
			;; PLace into invenotry
			finalItem=ref.PlaceAtMe(itemToSpawnBase,1,true,true) 
			finalItem.SetDisplayName(itemname,true)
			finalItem.SetName(itemname)
			ref.AddItem(finalItem,1,true)
		else 
			
			finalItem=ref.PlaceAtMe(itemToSpawnBase,1,true,true) 
			finalItem.SetDisplayName(itemname,true)
			finalItem.SetName(itemname)
		endif;
		
		
		finalItem.SetFactionOwner(AIAssisted)
		Game.getPlayer().AddToFaction(AIAssisted); So item is not marked as stolen
		
		if (finalItem.Is3DLoaded())
			float deltaX=Utility.RandomFloat(-1, 1)
			float deltaY=Utility.RandomFloat(-1, 1)
			float deltaZ=Utility.RandomFloat(1,1)*-1
			finalItem.MoveTo(ref, 0,0,deltaZ)
			finalItem.SetAngle(0,-180,0)
		Endif
		
		finalItem.SetScale(2)
		finalItem.Enable()
		
		AIAgentFunctions.logMessage("spawned_item@"+itemname+"@success@"+referencename,"status_msg")
		Debug.Trace("[CHIM] spawned_item "+itemname+" / itembase "+itembase+ " / location Marker:"+locationMarker+ "/ FormID"+finalItem.GetFormId());
		
		if (finalItem.Is3DLoaded())
			veff.Play(finalItem);
			hintSound.Play(finalItem)
		endif
		if (locationMarker==0)
			Debug.Notification("[CHIM] Something is hidding near "+referencename);	
		endif;
		
		RecipeManagerCreateSimple(finalItem.GetFormID(),None,None,None);
		
		return 0
	else
		AIAgentFunctions.logMessage("spawned_item@"+itemname+"@error","status_msg")
		Debug.Trace("[CHIM] ERROR spawning "+itemname+" / itembase "+itembase+ " / location Marker:"+locationMarker);
	EndIf

	return -1
EndFunction


int Function Sandbox(Actor npc,String taskid) global

	Package sandboxPackage = Game.GetFormFromFile(0x20ce2,"AIAgent.esp") as Package		; Package sandboxPackage 
	Faction sandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction
		
	npc.SetFactionRank(sandboxFaction,1)
	ActorUtil.AddPackageOverride(npc, sandboxPackage, 100,0)
	Debug.Trace("[CHIM] "+npc.GetDisplayName()+" is at "+npc.GetCurrentLocation().GetName())
	npc.EvaluatePackage();
	;AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" talks to "+(Game.GetPlayer().GetDisplayName())+" about the topic he/she knows","instruction",npc.GetDisplayName())
endFunction



int Function CombatPlayer(Actor npc) global
	Debug.Trace("CombatPlayer "+npc.GetDisplayName())
	
	npc.SetActorValue("Aggression",1)
	npc.SetRelationshipRank(Game.GetPlayer(), -4)
	npc.startCombat(Game.GetPlayer())
	AIAgentFunctions.logMessageForActor("combat_start@"+npc.GetDisplayName(),"status_msg",npc.GetDisplayName())
	
	
endFunction
	
function SendInstruction(Actor npc, String instruction) global
	
	AIAgentFunctions.requestMessageForActor(instruction,"instruction",npc.GetDisplayName())
	Debug.Trace("[CHIM] Instruction to: "+npc.GetDisplayName()+ ", "+instruction);

endFunction


function SendSuggestion(Actor npc, String instruction) global
	
	AIAgentFunctions.requestMessageForActor(instruction,"suggestion",npc.GetDisplayName())
	Debug.Trace("[CHIM] Suggestion to: "+npc.GetDisplayName()+ ", "+instruction);

endFunction

function SetDisposition(Actor npc, String disposition) global
	
	Debug.Trace("[CHIM] SetDisposition Start: "+npc.GetDisplayName()+ ", "+disposition);
	if (disposition=="defiant")
		npc.setAlert()
		npc.SetRelationshipRank(Game.GetPlayer(), -1)
		
	elseif (disposition=="furious")
		npc.setAlert()
		npc.SetRelationshipRank(Game.GetPlayer(), -1)
		
	EndIf
	
	Debug.Trace("[CHIM] SetDisposition End: "+npc.GetDisplayName()+ ", "+disposition);

endFunction

function Despawn(Actor npc) global

	Debug.Trace("[CHIM] Despawn "+npc.GetDisplayName());
	
	ObjectReference WIDeadBodyCleanupCellMarker  = Game.GetForm(0x001037f2) as ObjectReference  ; Beggar

	Debug.Trace("[CHIM] Reset "+npc.GetDisplayName());
	npc.Moveto(WIDeadBodyCleanupCellMarker)
	npc.KillSilent()
	Debug.Trace("[CHIM] Despawned: "+npc.GetDisplayName());
	
	return 
	Faction AttackFaction=Game.GetFormFromFile(0x01B6C1 , "AIAgent.esp") as Faction ; Faction AttackFaction
	Faction TravelFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	Faction WaitFaction=  Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	Faction SeatFaction=  Game.GetFormFromFile(0x01C6EA, "AIAgent.esp") as Faction ; Faction AIAgentFactionSeat

	;npc.RemoveFromFaction(moveToFaction)
	npc.RemoveFromFaction(AttackFaction)
	npc.RemoveFromFaction(FollowFaction)
	npc.RemoveFromFaction(TravelFaction)
	npc.RemoveFromFaction(WaitFaction)
	npc.RemoveFromFaction(SeatFaction)
	
	
	
	PO3_SKSEFunctions.SetLinkedRef(npc,None)
	
	npc.EvaluatePackage()
	
	Package TraveltoPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Package AttackPackage = Game.GetFormFromFile(0x01B6C2 , "AIAgent.esp") as Package ; Package AttackPackage
	Package FollowPackage = Game.GetFormFromFile(0x01BC25, "AIAgent.esp") as Package 
	Package SeatPackage = Game.GetFormFromFile(0x01C6E9, "AIAgent.esp") as Package ; Package SeatPackage
	Package MoveToPackage = Game.GetFormFromFile(0x01C6E8, "AIAgent.esp") as Package ; Package MoveToTarget
	Package WaitPackage = Game.GetFormFromFile(0x02021F, "AIAgent.esp") as Package ; Package MoveToTarget

	ActorUtil.RemovePackageOverride(npc, TraveltoPackage)
	ActorUtil.RemovePackageOverride(npc, AttackPackage)
	ActorUtil.RemovePackageOverride(npc, FollowPackage)
	ActorUtil.RemovePackageOverride(npc, SeatPackage)
	ActorUtil.RemovePackageOverride(npc, MoveToPackage)
	ActorUtil.RemovePackageOverride(npc, WaitPackage)
	ActorUtil.ClearPackageOverride(npc)
	
	
endFunction

Function EndQuestNotification(String title,String taskid) global
	Debug.Notification("[CHIM] Adventure ends. "+title);
	QuestNotifySound()
	
	
EndFunction

Function StartQuestNotification(String title,String taskid) global
	Debug.Notification("[CHIM] Adventure starts. "+title);
	QuestNotifySound()
	
EndFunction

Function AddDelayedHint(ObjectReference finalItem) global
	
	VisualEffect veff=Game.GetForm(0x0008cc8a)  as VisualEffect	
	Sound hintSound =Game.GetFormFromFile(0x0237F4,"AIAgent.esp")  as Sound	
		
	if (finalItem.Is3DLoaded())
		veff.Play(finalItem);
		hintSound.Play(finalItem)
	Endif
		
	Debug.Trace("[CHIM] spawned_item_activated: "+finalItem.GetDisplayName()+" at "+finalItem.GetCurrentLocation().GetName());
		

EndFunction

Function AddDelayedNPC(Actor akActor) global

	if (StorageUtil.HasFormValue(akActor,"CustomHairColor"))
		ColorForm HairColor=StorageUtil.GetFormValue(akActor, "CustomHairColor") as ColorForm
		PO3_SKSEFunctions.SetHairColor(akActor,HairColor )	
		Debug.Trace("[CHIM] AddDelayedNPC: "+akActor.GetDisplayName()+" at "+HairColor.GetName());
	endif
		

EndFunction

Function QuestNotifySound() global
	
	Debug.Trace("QuestNotifySound start");
	Sound aiqueststart = Game.GetForm(0x00018538) as Sound	; Pututum
	aiqueststart.Play(Game.GetPlayer())
	Debug.Trace("QuestNotifySound end");

EndFunction


Function RecipeManagerCreateSimple(int resultId,Form source1,Form source2,Form source3) global
	
	return;
	Debug.Trace("RecipeManagerCreateSimple start");
	MiscObject item=Game.GetFormEx(resultId) as MiscObject;
	ConstructibleObject  genericCons = Game.GetFormFromFile(0x0242b7, "AIAgent.esp") as ConstructibleObject ; Package Travelto
		
	genericCons.setName("Ethereal forge");
	item.setName("Ethereal Ring")
	genericCons.setResultQuantity(1);
	genericCons.setResult(item);
	Debug.Trace("RecipeManagerCreateSimple end");
	
EndFunction

Function MoveInventoryItem(Actor source, Actor target, Form akItemToRemove,int amount,string realName) global
	
	Debug.Trace("MoveInventoryItem start");
	if (akItemToRemove.GetFormID()==0xf)
	
		string result = SkyMessage.Show(target.GetDisplayName()+ " wants to take "+amount+" gold from you. Allow?", "No, thanks", "Yes, please!")

		if result == "Yes, please!"
			source.RemoveItem(akItemToRemove, amount)
			target.AddItem(akItemToRemove,amount)
			AIAgentFunctions.logMessageForActor(source.GetDisplayName()+" gave "+amount+" Gold to "+target.GetDisplayName(),"itemfound",target.GetDisplayName())	
		else
			AIAgentFunctions.logMessageForActor(source.GetDisplayName()+" rejected the transaction of "+amount+" gold!!!!","itemfound",target.GetDisplayName())	
		endif	
		
	else
		source.RemoveItem(akItemToRemove, 1, false, target)
		Debug.Notification(source.GetDisplayName()+ " has give you "+realName);
		;TESCOntainerEvent will take care of the transaction
	endif
	Debug.Trace("MoveInventoryItem end");
	
	

EndFunction

; New function to handle NPC-to-NPC item transfers
; Called directly from C++ with all necessary parameters
Function GiveItemToTarget(Actor source, Actor target, Form itemForm, int amount, string itemName) global
	Debug.Trace("[CHIM] GiveItemToTarget: "+source.GetDisplayName()+" -> "+target.GetDisplayName()+": "+amount+" "+itemName)
	
	if (!source || !target || !itemForm || amount <= 0)
		Debug.Trace("[CHIM] GiveItemToTarget: Invalid parameters")
		return
	endif
	
	; Check distance - if close enough, transfer immediately
	float distance = source.GetDistance(target)
	Debug.Trace("[CHIM] GiveItemToTarget: Distance = "+distance)
	
	if (distance < 512.0)
		; Close enough - transfer immediately
		Debug.Trace("[CHIM] GiveItemToTarget: Close enough, transferring immediately")
		source.RemoveItem(itemForm, amount, true, target)
		
		; Notify server of the transfer
		int currentTime = Utility.GetCurrentRealTime() as int
		int gameTime = Utility.GetCurrentGameTime() as int
		string logMessage = "itemtransfer|"+currentTime+"|"+gameTime+"|"+source.GetDisplayName()+" gave "+amount+" "+itemName+" to "+target.GetDisplayName()
		Debug.TraceUser("ChimHTTPSender", logMessage)
	else
		; Too far - store details and initiate movement
		Debug.Trace("[CHIM] GiveItemToTarget: Too far, initiating movement")
		StorageUtil.SetIntValue(source, "PendingGiveFormID", itemForm.GetFormID())
		StorageUtil.SetIntValue(source, "PendingGiveAmount", amount)
		StorageUtil.SetStringValue(source, "PendingGiveItem", itemName)
		
		; Make the NPC walk to the target
		MoveToTarget(source, target as ObjectReference, 1)
	endif
EndFunction

Function PickupItemFromWorld(Actor npc, ObjectReference itemRef, string itemName) global
	if (!npc || !itemRef)
		return
	endif
	
	; Check distance to item
	float distance
	distance = npc.GetDistance(itemRef)
	
	if (distance < 64.0)
		; Close enough - pick up immediately
		Debug.SendAnimationEvent(npc, "IdlePickup")
		Utility.Wait(0.5)
		
		; Activate the item to pick it up
		npc.Activate(itemRef)
		
		; Wait a moment for the pickup to process
		Utility.Wait(0.5)
		
		; Refresh the NPC's inventory so they know what they picked up
		Debug.TraceUser("ChimHTTPSender", "AIAgentRefreshInventory|"+npc.GetFormID())
		
		; Notify server of the pickup
		int currentTime
		currentTime = Utility.GetCurrentRealTime() as int
		int gameTime
		gameTime = Utility.GetCurrentGameTime() as int
		string logMessage
		logMessage = "itempickup|"+currentTime+"|"+gameTime+"|"+npc.GetDisplayName()+" picked up "+itemName
		Debug.TraceUser("ChimHTTPSender", logMessage)
		
		Debug.Notification(npc.GetDisplayName()+" picked up "+itemName)
	else
		; Too far - store details and initiate movement
		StorageUtil.SetStringValue(npc, "PendingPickupItem", itemName)
		
		; Make the NPC walk to the item (intent=4 for pickup)
		MoveToTarget(npc, itemRef, 4)
	endif
EndFunction


function PlaceCam(Actor npc) global

	
	int isActive=StorageUtil.GetIntValue(None, "AIAgentAutoFocusOnSit",1);
	if (!isActive)
		return
	endif
	
	if (Game.GetPlayer().GetSitState()==0 || (Game.GetPlayer().IsOnMount())) ; Dont use feature if player is not sitting, or is on a mount
		return;
	else
		;Debug.Trace("Player is sitting");
	endif
	
	Actor lastCamActor=StorageUtil.GetFormValue(None, "AIAgentAutoFocusOnSitLastActor",None) as Actor;
	if (lastCamActor==npc && false) ; activate to update cam per speech, not per spech line
		return
	endif;
	
	StorageUtil.SetFormValue(None, "AIAgentAutoFocusOnSitLastActor",npc);
	
	Actor player = Game.GetPlayer()
    ; Simple camera rotation to point view to speaker
    float angleToNPC = player.GetHeadingAngle(npc)
    ; Adjust the player's angle to face the NPC
	if (Math.abs(angleToNPC)>10 )
		if (angleToNPC>80)
			angleToNPC=80;
		elseif (angleToNPC<-80)
			angleToNPC=-80;
		endif;
		
		Game.SetSittingRotation(angleToNPC)	
    
		
	endif

	; Test code. Never fully worked.
	if (false)
		float distanceOffset=100
		Actor cameraActor=StorageUtil.GetFormValue(None, "AIAgentAutoFocusOnSitCameraMan",None) as Actor;
		if (!cameraActor)
			ActorBase newActorBase = Game.GetFormFromFile(0x0278d6,"AIAgent.esp") as ActorBase 
			newActorBase.SetHeight(1);
			ObjectReference newCameraReference = Game.GetPlayer().PlaceAtMe(newActorBase, 1, false, true)
			cameraActor=newCameraReference as Actor
			cameraActor.Enable();
			cameraActor.SetAlpha(0)
			cameraActor.EnableAI(false)		
			Game.SetCameraTarget(cameraActor)
			StorageUtil.SetFormValue(None, "AIAgentAutoFocusOnSitCameraMan",cameraActor);
		endif;

		if (cameraActor)
			
			cameraActor.Disable();
			;newActor.MoveTo(npc, Math.Sin(npc.GetAngleZ()) * distanceOffset, Math.Cos(npc.GetAngleZ()) * distanceOffset, 0,true)
			;newActor.SetAngle(npc.GetAngleX(), npc.GetAngleY(), npc.GetAngleZ()+180.0)
			float x=npc.X+Math.Sin(npc.GetAngleZ()) * distanceOffset
			float y=npc.Y+Math.Cos(npc.GetAngleZ()) * distanceOffset
			float z=npc.Z
			
			float dx = x - cameraActor.GetPositionX()
			float dy = y - cameraActor.GetPositionY()
			float dz = z - cameraActor.GetPositionZ()
	
			float delta = Math.Sqrt(dx * dx + dy * dy + dz * dz);
			if (delta>50)
				cameraActor.TranslateTo(x, y, z, npc.GetAngleX(), npc.GetAngleY(), npc.GetAngleZ()+180, 99999, 0)
				cameraActor.Enable();
				cameraActor.SetAlpha(0)
			else
				cameraActor.Enable();
				cameraActor.SetAlpha(0)
			endif
		endif
		
	endif

	;Debug.Trace("[CHIM] Camera focus on "+npc.GetDisplayName())


EndFunction

function resetCam() global
	
	
		
	
endFunction


Function GatherAround()  global

	
	
	Actor[] actors = AIAgentFunctions.findAllNearbyActors(true)
	; remove player actor from the list
	;actors = PapyrusUtil.RemoveActor(actors,Game.GetPlayer())
	int i = actors.length - 1
	Actor actorAtIndex = None
	
	; iterating reversed as we modify the array
	while i>=0
		actorAtIndex = actors[i]
		bool mustCome= true
		;mustCome = mustCome && (!actorAtIndex.IsHostileToActor(Game.GetPlayer()))	; Hostiles wont come
		;mustCome = mustCome && (actorAtIndex.Getrace().isPlayable())				; Only playable races
		if (mustCome) 
			Debug.Trace("[CHIM] "+actorAtIndex.getDisplayName() +" will come to player"); 
			stayAtPlace(actorAtIndex,1,"papyrus");
		else
			Debug.Trace("[CHIM] "+actorAtIndex.getDisplayName() +" won't  come to player"); 
		Endif
		i -= 1
	endwhile

	;AIAgentFunctions.logMessage(Game.getPlayer().GetDisplayName()+" calls everyone around","infoaction");
	AIAgentFunctions.requestMessage(Game.getPlayer().GetDisplayName()+" calls everyone around","bored");

endFunction

Function addRenamedKeyword(ObjectReference akTarget,string newName) global
	Form  AIAgentNoRenameMarker = Game.GetFormFromFile(0x02481f,"AIAgent.esp") as Form 	; Check this form
	akTarget.AddItem(AIAgentNoRenameMarker,1,true)
	Actor akTargetActor=akTarget as Actor
	StorageUtil.SetStringValue(akTarget,"forcedName",newName)
	Debug.Trace("[CHIM] Added avoid renaming item to "+akTargetActor.GetDisplayName()); 

endFunction

; Experiment.
bool Function projectNPC(Form actorForm) global

	Package doNothing = Game.GetForm(0x654e2) as Package ; Package Travelto

	Actor aktarget = actorForm as Actor
	
	Debug.Trace("[CHIM] projectNPC actor: "+aktarget.GetDisplayName())
	
	akTarget.SetAllowFlying(true);
	akTarget.SetDontMove(true);
	akTarget.SetLookAt(Game.GetPlayer(),true)
	akTarget.setScale(0.3);
	akTarget.SetAnimationVariableBool("bHumanoidFootIKDisable", False)
	akTarget.SetMotionType(4)
	ActorUtil.AddPackageOverride(akTarget, doNothing,100)

	Actor PlayerRef = Game.GetPlayer()
	;akTarget.Disable(false)
	;akTarget.EnableAI(false)
	akTarget.MoveTo(PlayerRef, 120.0 * Math.Sin(PlayerRef.GetAngleZ()), 120.0 * Math.Cos(PlayerRef.GetAngleZ()), PlayerRef.GetHeight() - 25.0 , false)
	akTarget.setGhost(true)
	akTarget.setAlpha(0.5)
	;akTarget.Enable(false)
	akTarget.QueueNiNodeUpdate();
	float angleToPlayer = akTarget.GetHeadingAngle(PlayerRef)
	akTarget.SetAngle(0.0, 0.0, PlayerRef.GetAngleZ() + angleToPlayer)
	;ActorUtil.RemovePackageOverride(akTarget, doNothing)

EndFunction


Int Function StringToInt(String str) global
    If str == ""
        Return 0
    EndIf

    Int len = StringUtil.GetLength(str)
    Int result = 0
    Int sign = 1
    Int i = 0

    ; Handle optional minus sign
    If StringUtil.GetNthChar(str, 0) == "-"
        sign = -1
        i = 1
    EndIf

    While i < len
        String c = StringUtil.GetNthChar(str, i)
        If StringUtil.IsDigit(c)
            Int digit = StringUtil.AsOrd(c) - StringUtil.AsOrd("0")
            result = result * 10 + digit
        Else
            ; Non-digit character encountered – invalid number
            Return 0  ; or handle error as needed
        EndIf
        i += 1
    EndWhile

    Return sign * result
EndFunction

String Function DecToHex(Int n) global
	String hexChars = "0123456789ABCDEF"
	String res = ""
	Int count = 0

	; Handle zero explicitly
	If n == 0
		res = "0"
		count = 1
	Else
		While n > 0
			res = StringUtil.GetNthChar(hexChars, n % 16) + res
			n /= 16
			count += 1
		EndWhile
	EndIf

	; Pad with leading zeros if needed
	While count < 8
		res = "0" + res
		count += 1
	EndWhile

	Return res
EndFunction

bool Function BackgroundCmd(Form actorForm,string command) global

	Actor aktarget = actorForm as Actor
	
	if (akTarget)
		Debug.Trace("[CHIM] BackgroundCmd, actor: "+aktarget.GetDisplayName())
		String[] cmd = StringUtil.Split(command, "/")
		Debug.Trace("[CHIM] BackgroundCmd, parm0: "+cmd[0])
		if cmd.length>1
			Debug.Trace("[CHIM] BackgroundCmd, parm1: "+cmd[1])
		endif
		
		if (cmd[0] == "TravelTo") 
			Int locrefId=StringToInt(cmd[1])
			Location destination = Game.GetFormEx(locrefId) as Location;
			if (destination)
				Debug.Trace("[CHIM] BackgroundCmd, destination: "+destination.GetName()+ ", FormId:"+DecToHex(locrefId))
				ObjectReference destMarker= AIAgentFunctions.getWorldLocationMarkerFor(destination);
				Debug.Trace("[CHIM] BackgroundCmd, destMarker: "+DecToHex(destMarker.GetFormId()))
				
				if (destMarker)
					TravelToLocation(akTarget,destMarker,destination.GetName())
				endif
			else
				Debug.Trace("[CHIM] BackgroundCmd, Couldn't find destination for formId: "+DecToHex(locrefId))
			endif
		elseif 	(cmd[0] == "SendNote") 
			
			WICourierScript  courier = Game.GetFormEx(0x00039f82) as WICourierScript;
			
			if (courier)
				Debug.Trace("[CHIM] BackgroundCmd, SendNote: "+cmd[1])
				Book itemToSpawnBase=Game.GetFormFromFile(0x022d30, "AIAgent.esp") as Book ; Package Travelto
				ObjectReference finalItem=Game.GetPlayer().PlaceAtMe(itemToSpawnBase,1,true,true) 
				finalItem.setDisplayName(cmd[1]);
				courier.addRefToContainer(finalItem)
				
			else
				Debug.Trace("[CHIM] BackgroundCmd, Couldn't find WICourierScript")
			endif

		elseif 	(cmd[0] == "ReturnHome") 
			
			ResetPackages(akTarget); SHould apply default NPC package
			
		elseif 	(cmd[0] == "StayAtPlace") 
			; TO-DO select a better package here
			Package doNothing = Game.GetForm(0x654e2) as Package ; Package Travelto
			ActorUtil.AddPackageOverride(akTarget, doNothing,99)
			
		elseif 	(cmd[0] == "Track") 
			float x = 0;
			float y = 0
			float z = 0
			string name
			
			Location loc= akTarget.GetCurrentLocation()
			Location currParentLvl1=PO3_SKSEFunctions.GetParentLocation(loc)
			Location currParentLvl2=PO3_SKSEFunctions.GetParentLocation(currParentLvl1)
			string lvl1s = ""
			string lvl2s = ""
			if currParentLvl1
				lvl1s = currParentLvl1.GetName()
			endif
			if currParentLvl2
				lvl2s = currParentLvl2.GetName()
			endif

			bool useRawCoords= false
			;;useRawCoords = !akTarget.IsInInterior() 
			Worldspace cws= akTarget.GetWorldSpace()
			
			Debug.Trace("[CHIM] "+akTarget.GetDisplayName()+"/"+loc.GetName()+"/"+lvl1s+"/"+lvl2s+" worldspace "+cws.GetName())

			if (cws.GetName() == "Skyrim" || cws.GetName() == "")
				if !akTarget.IsInInterior() 
					useRawCoords = true
				endif
			endif
			
			if (useRawCoords)
				x=akTarget.GetPositionX();
				y=akTarget.GetPositionY();
				z=akTarget.GetPositionZ();
				name=loc.GetName();
				Debug.Trace("[CHIM] BackgroundCmd, "+akTarget.GetDisplayName()+",Not interior, akTarget.GetPosition, Track: "+x+","+y+","+z);
			else
				ObjectReference destMarker=AIAgentFunctions.getWorldLocationMarkerFor(loc);
				if (!destMarker)
					destMarker=AIAgentFunctions.getWorldLocationMarkerFor(currParentLvl1);
					Debug.Trace("[CHIM] BackgroundCmd, "+akTarget.GetDisplayName()+" loc.parent.GetPosition , Track: "+currParentLvl1.GetName()+ ": "+x+","+y+","+z);
				endif;
				if (destMarker)
					
					x=destMarker.GetPositionX();
					y=destMarker.GetPositionY();
					z=destMarker.GetPositionZ();
					Debug.Trace("[CHIM] BackgroundCmd, "+akTarget.GetDisplayName()+" loc.GetPosition, Track: "+loc.GetName()+ ": "+x+","+y+","+z);
					name=loc.GetName()
				else
					x=akTarget.GetPositionX();
					y=akTarget.GetPositionY();
					z=akTarget.GetPositionZ();
					name=loc.GetName();
					Debug.Trace("[CHIM] BackgroundCmd, "+akTarget.GetDisplayName()+" akTarget.GetPosition, Track: "+x+","+y+","+z);
				endif
			endif

			int retFnc=AIAgentFunctions.logMessage(akTarget.GetDisplayName()+"/"+x+"/"+y+"/"+z+"/"+name,"util_location_npc")
		endif
	endif
	

EndFunction

; Helper function to convert FormID to hex string (last 4 digits only)
string Function GetFormIDHexString(int formID) global
	string hexChars
	hexChars = "0123456789ABCDEF"
	
	; We only care about the last 4 hex digits (16 bits) for disambiguation
	; This avoids issues with negative numbers and is sufficient to distinguish duplicates
	int workingID
	workingID = formID
	
	; If negative, mask to get positive representation of lower bits
	if (workingID < 0)
		workingID = workingID + 2147483648  ; Add 2^31 to flip sign bit
		workingID = workingID + 2147483648  ; Add another 2^31 (total +2^32 equivalent)
	endif
	
	; Build last 4 hex digits only
	string result
	result = ""
	int remainingValue
	remainingValue = workingID
	int digitCount
	digitCount = 0
	
	; Get last 4 hex digits (16 bits)
	while (digitCount < 4)
		int digit
		digit = remainingValue % 16
		result = StringUtil.GetNthChar(hexChars, digit) + result
		remainingValue = remainingValue / 16
		digitCount += 1
	endWhile
	
	return result
EndFunction

; Cast Fire & Forget or instant spells - simplified to just cast on target
function CastSpellOnTarget(Actor caster, int spellFormId, int targetFormId) global
	Spell spellToCast = Game.GetForm(spellFormId) as Spell
	Actor target = Game.GetForm(targetFormId) as Actor
	
	if (!spellToCast)
		Debug.Notification("[CHIM] Spell not found")
		return
	endif
	
	if (!caster.HasSpell(spellToCast))
		Debug.Notification("[CHIM] " + caster.GetDisplayName() + " doesn't know " + spellToCast.GetName())
		return
	endif
	
	; Simply cast the spell on the target
	spellToCast.Cast(caster, target)
	
	Debug.Notification("[CHIM] " + caster.GetDisplayName() + " casts " + spellToCast.GetName())
	
	; Log the spell cast event
	AIAgentFunctions.logMessageForActor(caster.GetDisplayName() + " casts " + spellToCast.GetName(), "npcspellcast", caster.GetDisplayName())
endFunction

; Cast Concentration spells - cast and interrupt after 3-5 seconds
function CastConcentrationSpell(Actor caster, int spellFormId, int targetFormId) global
	Spell spellToCast = Game.GetForm(spellFormId) as Spell
	Actor target = Game.GetForm(targetFormId) as Actor
	
	if (!spellToCast)
		Debug.Notification("[CHIM] Spell not found")
		return
	endif
	
	if (!caster.HasSpell(spellToCast))
		Debug.Notification("[CHIM] " + caster.GetDisplayName() + " doesn't know " + spellToCast.GetName())
		return
	endif
	
	; Cast the spell (starts channeling for concentration spells)
	spellToCast.Cast(caster, target)
	
	Debug.Notification("[CHIM] " + caster.GetDisplayName() + " casts " + spellToCast.GetName())
	
	; Log the spell cast event
	AIAgentFunctions.logMessageForActor(caster.GetDisplayName() + " casts " + spellToCast.GetName(), "npcspellcast", caster.GetDisplayName())
	
	; Wait 3-5 seconds then stop the spell
	float channelDuration = Utility.RandomFloat(3.0, 5.0)
	Utility.Wait(channelDuration)
	
	; Interrupt the spell casting
	caster.InterruptCast()
endFunction

; Cast Constant Effect spells - simplified to just cast on target
function CastConstantSpell(Actor caster, int spellFormId, int targetFormId) global
	Spell spellToCast = Game.GetForm(spellFormId) as Spell
	Actor target = Game.GetForm(targetFormId) as Actor
	
	if (!spellToCast)
		Debug.Notification("[CHIM] Spell not found")
		return
	endif
	
	if (!caster.HasSpell(spellToCast))
		Debug.Notification("[CHIM] " + caster.GetDisplayName() + " doesn't know " + spellToCast.GetName())
		return
	endif
	
	; Simply cast the spell on the target
	spellToCast.Cast(caster, target)
	
	Debug.Notification("[CHIM] " + caster.GetDisplayName() + " casts " + spellToCast.GetName())
	
	; Log the spell cast event
	AIAgentFunctions.logMessageForActor(caster.GetDisplayName() + " casts " + spellToCast.GetName(), "npcspellcast", caster.GetDisplayName())
endFunction


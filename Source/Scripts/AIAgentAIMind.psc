Scriptname AIAgentAIMind 

Actor herika
Keyword property ActorTypeNPC auto
Actor lastTarget

function Test() global

Debug.Notification("Ok");

endFunction

function ResetPackages(Actor npc) global

	npc.EnableAI(false) 

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
	;ActorUtil.ClearPackageOverride(npc)
	
	npc.EvaluatePackage()
	
	SheatheWeapon(npc);
	npc.EnableAI(true) 


endFunction
function PlayerFollowStart() global

	

endFunction

function MoveToTarget(Actor npc, ObjectReference akTarget) global

	ResetPackages(npc);
	Package MoveToPackage = Game.GetFormFromFile(0x01C6E8, "AIAgent.esp") as Package ; Package MoveToTarget
	Faction MoveToFaction=Game.GetFormFromFile(0x01A69B, "AIAgent.esp") as Faction ; Faction MoveToTarget
	Keyword MoveTargetKw = Game.GetFormFromFile(0x21245,"AIAgent.esp") as Keyword	; // Psijic Monk Outfit
	npc.SetFactionRank(MoveToFaction,1)
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget,MoveTargetKw)
	ActorUtil.AddPackageOverride(npc, MoveToPackage, 99, 0)
	npc.EvaluatePackage()
	Debug.Notification("[CHIM] Moving to "+akTarget.GetDisplayName())
	AIAgentFunctions.logMessageForActor("started_moving@"+akTarget.GetDisplayName(),"status_msg",npc.GetDisplayName())

endFunction

function MoveToTargetEnd(Actor npc) global

	AIAgentFunctions.logMessageForActor("reached_destination@"+npc.GetDisplayName(),"status_msg",npc.GetDisplayName())
	Package MoveToPackage = Game.GetFormFromFile(0x01C6E8, "AIAgent.esp") as Package ; Package MoveToTarget
	Faction MoveToFaction=Game.GetFormFromFile(0x01A69B, "AIAgent.esp") as Faction ; Faction MoveToTarget
	Keyword MoveTargetKw = Game.GetFormFromFile(0x21245,"AIAgent.esp") as Keyword	; // Psijic Monk Outfit
	
	npc.RemoveFromFaction(MoveToFaction)
	ActorUtil.RemovePackageOverride(npc, MoveToPackage)

	PO3_SKSEFunctions.SetLinkedRef(npc,None,MoveTargetKw)
	npc.EvaluatePackage()
	
	AIAgentFunctions.commandEndedForActor("MoveTo",npc.GetDisplayName())

	string taskid = JDB.solveStr(".aiff.currentTaskId");

	Debug.Notification("[CHIM] End of move: "+npc.GetDisplayName())	
	Debug.Trace("[CHIM] End of move: "+npc.GetDisplayName()+" taskid:"+taskid)	
	

endFunction

function TakeASeat(Actor npc, ObjectReference akTarget) global
	
	
	Package SeatPackage = Game.GetFormFromFile(0x01C6E9, "AIAgent.esp") as Package ; Package AIAgentSeatPackage
	Faction SeatFaction=Game.GetFormFromFile(0x01C6EA, "AIAgent.esp") as Faction ; Faction AIAgentFactionSeat
	npc.SetFactionRank(SeatFaction,1)
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, SeatPackage, 100, 0)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	Debug.Notification("[CHIM] Sitting at "+akTarget.GetDisplayName())
	

endFunction

function TakeASeatEnd(Actor npc) global
	Package SeatPackage = Game.GetFormFromFile(0x01C6E9, "AIAgent.esp") as Package ; Package MoveToTarget
	Faction SeatFaction=Game.GetFormFromFile(0x01C6EA, "AIAgent.esp") as Faction ; Faction MoveToTarget
	npc.RemoveFromFaction(SeatFaction)
	ActorUtil.RemovePackageOverride(npc, SeatPackage)

	npc.EvaluatePackage()
	PO3_SKSEFunctions.SetLinkedRef(npc,None)
	AIAgentFunctions.commandEnded("TakeASeat")
	Debug.Notification("[CHIM] End of sit: "+npc.GetDisplayName())
	

endFunction



function SneakToTarget(Actor npc, ObjectReference akTarget) global
	

endFunction

function SneakToTargetEnd(Actor npc) global

	

endFunction


function StartWait(Actor npc) global


	Debug.Trace("[CHIM] "+npc.GetDisplayName()+" waits" )

	Package WaitPackage = Game.GetFormFromFile(0x02021F, "AIAgent.esp") as Package ; Package WaitPackage
	Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	
	npc.SetFactionRank(WaitFaction,1)
	
	ActorUtil.AddPackageOverride(npc, WaitPackage, 100, 0)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	Debug.Notification("[CHIM] "+npc.GetDisplayName()+" waits" )
	

endFunction

function EndWait(Actor npc) global
	Package WaitPackage = Game.GetFormFromFile(0x02021F, "AIAgent.esp") as Package ; Package WaitPackage
	Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 
	npc.RemoveFromFaction(WaitFaction)
	ActorUtil.RemovePackageOverride(npc, WaitPackage)

	npc.EvaluatePackage()
	
	AIAgentFunctions.commandEnded("WaitHere")
	Debug.Notification("[CHIM] End of wait: "+npc.GetDisplayName())

endFunction



function Follow(Actor npc, ObjectReference akTarget) global
	
	
	ResetPackages(npc);
	Package FollowPackage = Game.GetFormFromFile(0x01BC25, "AIAgent.esp") as Package 
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
	
	
	
	npc.SetFactionRank(FollowFaction,1)
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, FollowPackage, 100, 0)
	npc.EvaluatePackage()
	Debug.Notification("[CHIM] Following  "+akTarget.GetDisplayName())

	
	
endFunction

function StopCurrent(Actor npc) global
	npc.EnableAI(false) 
	npc.stopCombat()
	
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

function TravelToLocation(Actor npc, ObjectReference akTarget,String place) global
	ResetPackages(npc);
	Package TraveltoPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Faction TraveToFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	npc.SetFactionRank(TraveToFaction,1)
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, TraveltoPackage, 100, 0)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	Debug.Notification("[CHIM] "+npc.GetDisplayName()+ " starts travel to "+place)
endFunction

function TravelToTargetEnd(Actor npc) global
	Package TravelPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Faction TravelFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	npc.RemoveFromFaction(TravelFaction)
	ActorUtil.RemovePackageOverride(npc, TravelPackage)

	PO3_SKSEFunctions.SetLinkedRef(npc,None)
	npc.EvaluatePackage()
	
	AIAgentFunctions.commandEndedForActor("TravelTo",npc.GetDisplayName())
	Debug.Notification("[CHIM] End travelling for "+npc.GetDisplayName() )

endFunction

function OpenInventory(Actor npc) global
	Faction CurrentFollowerFaction=Game.GetForm(0x5c84e) as Faction
	Debug.Notification("[CHIM] OpenInventory "+npc.GetDisplayName() )
	if (npc.IsPlayerTeammate())
		if (npc.GetFactionRank(CurrentFollowerFaction)>-1)
			Debug.Trace("[CHIM] Call OpenInventory "+npc.GetDisplayName() )
			npc.OpenInventory(true);
		else	
			Debug.Trace("[CHIM] Call ShowBarterMenu "+npc.GetDisplayName() )
			npc.ShowBarterMenu();
		endif
	else
		Debug.Trace("[CHIM] Call ShowGiftMenu "+npc.GetDisplayName() )
		npc.ShowGiftMenu(true,None,false,false);
	endif
endFunction




function AttackTarget(Actor npc, ObjectReference akTarget) global
		
	ResetPackages(npc);
	Package AttackPackage = Game.GetFormFromFile(0x01B6C2 , "AIAgent.esp") as Package 
	Faction AttackFaction=Game.GetFormFromFile(0x01B6C1 , "AIAgent.esp") as Faction 
	npc.SetFactionRank(AttackFaction,1)
	
	Actor targetAsActor = akTarget as Actor
	
	;Faction WEPlayerEnemy=Game.GetForm(0x0001DD0F) as Faction ; WEPlayerEnemy
	;targetAsActor.SetFactionRank(WEPlayerEnemy,1)
	
	
	;npc.ModActorValue("aggression", 3)
	;npc.ModActorValue("morality", 0)
	;npc.SetPlayerTeammate(false,true);
	if (targetAsActor)
		PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
		ActorUtil.AddPackageOverride(npc, AttackPackage, 99, 0)
		npc.EvaluatePackage()
		;npc.startCombat(targetAsActor);
		Debug.Notification("[CHIM] "+npc.GetDisplayName()+" attacks "+akTarget.GetDisplayName())
		AIAgentFunctions.logMessageForActor("command@Attack@"+akTarget.GetDisplayName()+"@"+npc.GetDisplayName()+" engages fair combat with "+akTarget.GetDisplayName(),"funcret",npc.GetDisplayName())
	else
		Debug.Notification("[CHIM] Could not reach target "+akTarget.GetDisplayName());
		;AIAgentFunctions.logMessage("command@Attack@"+akTarget.GetDisplayName()+"@"+npc.GetDisplayName()+" cannot attack "+akTarget.GetDisplayName(),"funcret")
		
	EndIf
	

endFunction


function AttackTargetEnd(Actor npc) global
	Package AttackPackage = Game.GetFormFromFile(0x01B6C2 , "AIAgent.esp") as Package 
	Faction AttackFaction=Game.GetFormFromFile(0x01B6C1 , "AIAgent.esp") as Faction 
	npc.RemoveFromFaction(AttackFaction)
	ActorUtil.RemovePackageOverride(npc, AttackPackage)

	npc.EvaluatePackage()
	PO3_SKSEFunctions.SetLinkedRef(npc,None)
	
	AIAgentFunctions.commandEndedForActor("Attack",npc.GetDisplayName())
	Debug.Notification("[CHIM] end attack command:  "+npc.GetDisplayName() )

endFunction

function StartCombat(Actor npc,ObjectReference victim) global


	Actor victimasActor = victim as Actor
	Debug.Trace("[CHIM] starting combat:  "+npc.GetDisplayName()+ " vs "+victim.GetDisplayName(),1)
		
	npc.startCombat(victimasActor);

	Debug.Notification("[CHIM] starting combat:  "+npc.GetDisplayName()+ " vs "+victim.GetDisplayName())

endFunction


function SendExternalEvent(String npcname,String command,String parm) global

	int handle = ModEvent.Create("CHIM_CommandReceived")
	if (handle)
		ModEvent.PushString(handle, npcname)
		ModEvent.PushString(handle, command)
		ModEvent.PushString(handle, parm)
		ModEvent.Send(handle)
		Debug.Notification("[CHIM] External command sent "+command+"@"+parm)

	endIf
endFunction

function SendExternalEventNPC(String npcname,String actionName) global

	int handle = ModEvent.Create("CHIM_NPC")
	if (handle)
		ModEvent.PushString(handle, npcname)
		ModEvent.PushString(handle, actionName)
		ModEvent.Send(handle)
		Debug.Trace("[CHIM] CHIM_NPC "+npcname+" "+actionName)
	endIf
endFunction


function SendExternalEventChat(String npcname,String text) global


	int handle = ModEvent.Create("CHIM_TextReceived")
	if (handle)
		ModEvent.PushString(handle, npcname)
		ModEvent.PushString(handle, text)
		ModEvent.Send(handle)
		Debug.Trace("[CHIM] CHIM_TextReceived sent "+npcname+"@"+text)
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
	
	Debug.Notification("[CHIM] "+npc.GetDisplayName())+" will wait here";
	;Topic fixedTopic=Game.GetFormFromFile(0x00638E, "AddDiagToReplace.esp") as Topic ; AASPGQuestDialogue2Topic1B1Topic
	;if (fixedTopic)
	;	npc.Say(fixedTopic,npc,false)
	;else
	;	Debug.Notification("[CHIM] Topic Not found")
	;endIf

endFunction


function FakeDialogue(Actor npc,int animation,int movehead) global
	
	npc.SetLookAt(Game.GetPlayer())
	
	if ((animation > 0) && !npc.IsInCombat())
		;npc.PlayIdle(Game.GetForm(0x000FFA0C) as Idle)
		npc.PlayIdle(Game.GetForm(animation) as Idle)
		
	else
		;Debug.SendAnimationEvent(npc, "IdleDialogueExpressiveStart")
	EndIf

endFunction

function LookAt(Actor npc,Actor target) global
	npc.SetLookAt(target)
endFunction

function PlayIdle(Actor npc,int animation) global

	npc.PlayIdle(Game.GetForm(animation) as Idle)
	
endFunction



function FakeDialogueWith(Actor npc,Actor listener, int animation,int movehead) global

	if ((animation > 0) && !npc.IsInCombat())
		npc.PlayIdle(Game.GetForm(animation) as Idle)
	else
		;Debug.SendAnimationEvent(npc, "IdleDialogueExpressiveStart")	
	EndIf
	if (movehead == 1 || true)
		npc.SetLookAt(listener)
		listener.SetLookAt(npc)
	endif	

endFunction


function PrepareForDialog(Actor npc) global
	; Before LLM response. User just talked.
	
	;AIAgentFaceReset.resetFace(npc);
	

endFunction

function resetExpression(Actor target) global
	
	;AASPGHerikaFaceReset.resetExpression(target);

endFunction


function EndDialogue(Actor npc) global
	
	;;npc.ClearLookAt()
	
endFunction

function EndDialogueClear(Actor npc) global
	npc.ClearLookAt()
	npc.EvaluatePackage()
	
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


int Function SpawnAgent(string npcName,Int FormIdNPC,Int FormIdClothing, Int FormIdWeapon,Int place,String taskid) global

	ObjectReference ref;
	bool move=true;
	if (place==0)
		if (Game.GetPlayer().IsInInterior())
			ref=AIAgentFunctions.getNearestDoor();
			if (!ref)
				ref=AIAgentFunctions.findLocationsToSafeSpawn(4096,false);
			else 
				move=false;
			endif
		else
			ref=AIAgentFunctions.findLocationsToSafeSpawn(6000,false);
		endif
	else
		ref=Game.GetForm(place) as ObjectReference
	endif
	
	if (ref)
		Debug.Trace("spawning "+npcName+" / FormIdNPC "+FormIdNPC+ " / FormIdClothing:"+FormIdClothing+" / FormIdWeapon: "+FormIdWeapon);		
		ActorBase finalNpcToSpawn ;
		finalNpcToSpawn = Game.GetForm(FormIdNPC) as ActorBase	; ImperialMalePreset01
		
		Outfit clothing 
		clothing = Game.GetForm(FormIdClothing) as Outfit  
		
		Weapon mainWeapon=Game.GetForm(FormIdWeapon)	as Weapon
		
		
		Actor finalActor=ref.PlaceAtMe(finalNpcToSpawn,1,true,true) as Actor
		
		if (move) 
			float deltaX=Utility.RandomFloat(-5, 5)
			float deltaY=Utility.RandomFloat(-5, 5)
			float deltaZ=Utility.RandomFloat(1,1)*1
			finalActor.MoveTo(ref, 0,0,deltaZ)
			finalActor.SetAngle(0,-180,0)
		endif;
		
		finalActor.RemoveAllItems();
		finalActor.SetActorValue("Aggression",0)
		finalActor.RemoveFromAllFactions();
		finalActor.MakePlayerFriend();
		finalActor.SetRelationshipRank(Game.GetPlayer(), 1)
		
		finalActor.enable();
		
		finalActor.SetOutfit(clothing,false)
		finalActor.SetDisplayName(npcName,1)
		
		finalActor.EvaluatePackage()
		finalActor.AddItem(mainWeapon,1,true)
		finalActor.EquipItem(mainWeapon,false,true)
		;AIAgentAIMind.StartWait(finalActor)
		AIAgentFunctions.setDrivenByAIA(finalActor,false)

		;ObjectReference currentloc = AIAgentFunctions.getLocationMarkerFor(Game.GetPlayer().GetCurrentLocation())
		;Debug.Trace("* [CHIM X] Marker "+currentloc.GetFormId());

		AIAgentFunctions.logMessageForActor("spawned@"+finalActor.GetDisplayName(),"status_msg",finalActor.GetDisplayName())

		if (place==0)
			Sound aiqueststart = Game.GetForm(0x00018538) as Sound	; Pututum
			aiqueststart.Play(Game.GetPlayer())
		endif
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

	Debug.Trace("spawning "+itemname+" / itembase "+itembase+ " / location Marker:"+locationMarker);
	
	ObjectReference ref
	if (locationMarker==0)
		ref=AIAgentFunctions.findLocationsToSafeSpawn(4096)
	else 
		ref=Game.GetForm(locationMarker)  as ObjectReference;
	endif

	if (ref)
		String referencename=ref.GetDisplayName();
		if (referencename=="")
			referencename=ref.GetName();
		endif
		
		
		Armor itemToSpawnBase=Game.GetForm(itembase)	as Armor; Necklace
		itemToSpawnBase.SetName(itemname)

		Armor itemToSpawn =itemToSpawnBase.TempClone() as Armor;
		
		EffectShader shader=Game.GetForm(0x00092de7)  as EffectShader	
		Enchantment ench=Game.GetForm(0x0010fb84)  as Enchantment	
		VisualEffect veff=Game.GetForm(0x0008cc8a)  as VisualEffect	
		Spell spellitem=Game.GetForm(0x043323)  as Spell	
		
		Faction AIAssisted = Game.GetFormFromFile(0x021d0b,"AIAgent.esp") as Faction	; 
		Sound hintSound =Game.GetFormFromFile(0x0237F4,"AIAgent.esp")  as Sound	
		
		itemToSpawn.SetEnchantment(ench); must be done to base
		
		ObjectReference finalItem=ref.PlaceAtMe(itemToSpawn,1,true,true) 
		
		finalItem.SetDisplayName(itemname,true)
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
		Debug.Trace("spawned_item "+itemname+" / itembase "+itembase+ " / location Marker:"+locationMarker+ "/ FormID"+finalItem.GetFormId());
		
		if (finalItem.Is3DLoaded())
			veff.Play(finalItem);
			hintSound.Play(finalItem)
		endif
		
		Debug.Notification("Something is hidding near "+referencename);	
		;Debug.Notification("Something is hidding nearby");	
		return 0
	else
		AIAgentFunctions.logMessage("spawned_item@"+itemname+"@error","status_msg")
	EndIf

	return -1
EndFunction

int Function MoveToPlayer(Actor npc,String taskid) global

	Package FollowPlayerPackage = Game.GetFormFromFile(0x2226d,"AIAgent.esp") as Package		; FollowPlayerPackage
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
			
	Actor finalActor=npc;
	finalActor.SetFactionRank(FollowFaction,1)
	ActorUtil.AddPackageOverride(finalActor, FollowPlayerPackage, 75,0)
		
	AIAgentAIMind.MoveToTarget(npc,Game.GetPlayer()); 
	AIAgentFunctions.logMessageForActor("moving@"+npc.GetDisplayName()+"@"+taskid,"status_msg",npc.GetDisplayName())

EndFunction

int Function Sandbox(Actor npc,String taskid) global

	Package sandboxPackage = Game.GetFormFromFile(0x20ce2,"AIAgent.esp") as Package		; Package sandboxPackage 
	Faction sandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction

	
	ActorUtil.RemovePackageOverride(npc, sandboxPackage)
	npc.RemoveFromFaction(sandboxFaction)
	

	Package FollowPlayerPackage = Game.GetFormFromFile(0x2226d,"AIAgent.esp") as Package		; FollowPlayerPackage
	Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 	
	Actor finalActor=npc;
	finalActor.SetFactionRank(sandboxFaction,1)
	ActorUtil.AddPackageOverride(finalActor, sandboxPackage, 98,0)
	
	finalActor.EvaluatePackage();
	;AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" talks to "+(Game.GetPlayer().GetDisplayName())+" about the topic he/she knows","instruction",npc.GetDisplayName())
endFunction

int Function stayAtPlace(Actor npc,int followPlayer,String taskid) global

	Utility.wait(1)
	ResetPackages(npc);
	Utility.wait(1)
	if (followPlayer==0)
		Package SandboxPackage = Game.GetFormFromFile(0x20ce2,"AIAgent.esp") as Package		; Package sandboxPackage 
		Faction SandboxFaction=Game.GetFormFromFile(0x21246, "AIAgent.esp") as Faction 		; Faction sandboxFaction

		Package WaitPackage = Game.GetFormFromFile(0x02021F, "AIAgent.esp") as Package ; Package WaitPackage
		Faction WaitFaction=Game.GetFormFromFile(0x02021E, "AIAgent.esp") as Faction 

		Actor finalActor=npc;	
		finalActor.SetFactionRank(WaitFaction,1)
		finalActor.SetFactionRank(SandboxFaction,1)
		ActorUtil.AddPackageOverride(finalActor, SandboxPackage, 98,0)
		ActorUtil.AddPackageOverride(finalActor, WaitPackage, 99,0)
		finalActor.EvaluatePackage();
	elseif (followPlayer==1)
		
		Package FollowPlayerPackage = Game.GetFormFromFile(0x2226d,"AIAgent.esp") as Package		; FollowPlayerPackage
		Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
			
		Actor finalActor=npc;
		finalActor.SetFactionRank(FollowFaction,1)
		ActorUtil.AddPackageOverride(finalActor, FollowPlayerPackage, 98,0)
		finalActor.EvaluatePackage();
	endif
	
	
	;AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" talks to "+(Game.GetPlayer().GetDisplayName())+" about the topic he/she knows","instruction",npc.GetDisplayName())

EndFunction


int Function CombatPlayer(Actor npc) global
	Debug.Trace("CombatPlayer "+npc.GetDisplayName())
	
	npc.SetActorValue("Aggression",1)
	npc.SetRelationshipRank(Game.GetPlayer(), -4)
	npc.startCombat(Game.GetPlayer())
	AIAgentFunctions.logMessageForActor("combat_start@"+npc.GetDisplayName(),"status_msg",npc.GetDisplayName())
	
	
endFunction
	
function TravelToTarget(Actor npc, ObjectReference akTarget,String place) global
	Debug.Trace("TravelToTarget called: "+npc.GetDisplayName())
	ResetPackages(npc);
	AIAgentFunctions.logMessageForActor(npc.GetDisplayName()+" leaves the place while talking","suggestion",npc.GetDisplayName())
	Utility.wait(5);
	Package TraveltoPackage = Game.GetFormFromFile(0x01ABFE, "AIAgent.esp") as Package ; Package Travelto
	Faction TraveToFaction=Game.GetFormFromFile(0x01A69C, "AIAgent.esp") as Faction ; Faction TravelTo
	npc.SetFactionRank(TraveToFaction,1)
	PO3_SKSEFunctions.SetLinkedRef(npc,akTarget)
	ActorUtil.AddPackageOverride(npc, TraveltoPackage, 100, 0)
	npc.EvaluatePackage()
	
	;Debug.Notification("Mission MoveToTarget start")
	if (place=="")
		place="a Unknown Place";
	endif;
	Debug.Notification("[CHIM] "+npc.GetDisplayName()+ " starts travel to "+place);

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

int Function EndQuestNotification(String title,String taskid) global
	Debug.Notification("[CHIM] Mysterious encounter ends!. "+title);
	Sound aiqueststart = Game.GetForm(0x00018538) as Sound	; Pututum
	aiqueststart.Play(Game.GetPlayer())
	
EndFunction

Function AddDelayedHint(ObjectReference finalItem) global
	
	VisualEffect veff=Game.GetForm(0x0008cc8a)  as VisualEffect	
	Sound hintSound =Game.GetForm(0x000dce94)  as Sound	; Nirn sound
		
	if (finalItem.Is3DLoaded())
		veff.Play(finalItem);
		hintSound.Play(finalItem)
	Endif
		
	Debug.Trace("spawned_item_activated"+finalItem.GetDisplayName());
		

EndFunction


	